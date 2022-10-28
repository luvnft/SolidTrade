using System.Collections.Concurrent;
using Application.Common;
using Application.Common.Interfaces.Services;
using Application.Common.Interfaces.Services.TradeRepublic;
using Application.Errors;
using Application.Models.Dtos.TradeRepublic;
using Domain.Enums;
using Microsoft.Extensions.Configuration;
using Newtonsoft.Json;
using Newtonsoft.Json.Serialization;
using OneOf;
using Serilog;
using Serilog.Events;
using WebSocketSharp;
using WebSocket = WebSocketSharp.WebSocket;

namespace Application.Services.TradeRepublic;

public abstract class TradeRepublicApi : ITradeRepublicApi
{
    private readonly Dictionary<int, (PositionType, int)> _runningRequestsAsync = new();
    private readonly Dictionary<int, Action<string>> _runningRequests = new();
    private readonly Dictionary<int, string> _requestBodies = new();

    private readonly JsonSerializerSettings _jsonSerializerOptions;

    private readonly ILogger _logger = Log.ForContext<TradeRepublicApi>();
    private readonly IOngoingProductsService _ongoingProductsService;
    private readonly WebSocket _webSocket;
    private bool _isReconnect;
        
    private DateTime _lastMessageReceived = DateTime.Now;
    private int _latestId;
        
    protected TradeRepublicApi(IConfiguration configuration, IOngoingProductsService ongoingProductsService)
    {
        _ongoingProductsService = ongoingProductsService;
        
        _jsonSerializerOptions = new JsonSerializerSettings
        {
            ContractResolver = new DefaultContractResolver
            {
                NamingStrategy = new CamelCaseNamingStrategy()
            },
        };
            
        /*
        This turns off web socket logs. This is done as the trade republic api closes all connections periodically and
        would result in logging fatal logs even though these are expected.
        Since there is customizable way to fix this logging issue we turn off logging completely.
        */
        _webSocket = new WebSocket(configuration["TradeRepublic:ApiEndpoint"]) { Log = { Output = (_, _) => {} } };
            
        _webSocket.OnMessage += OnTradeRepublicMessage;
        _webSocket.OnOpen += (_, _) =>
        {
            _logger.Debug("Connected to trade republic api");
            _webSocket.Send(configuration["TradeRepublic:InitialConnectString"]);

            if (!_isReconnect)
                Task.Run(async () => await RegisterAllOngoingPosition());
        };

        _webSocket.OnClose += (_, _) =>
        {
            _logger.Debug("Trade republic api connection closed unexpectedly");
            _logger.Debug("Trying to reconnect");

            _isReconnect = true;
            _webSocket.Connect();
        };

        _webSocket.SslConfiguration.EnabledSslProtocols = System.Security.Authentication.SslProtocols.Tls12;
        _webSocket.Connect();
    }
        
    public void AddOngoingRequest(string isin, PositionType positionType, int entityId)
    {
        var id = GetNewId();
        _runningRequestsAsync.Add(id, (positionType, entityId));

        string content = "{\"type\":\"ticker\",\"id\":\"" + isin + "\"}";
            
        _webSocket.Send($"sub {id} {content}");
        _requestBodies.Add(id, content);
    }
        
    public async Task<OneOf<T, UnexpectedError>> AddRequest<T>(string content, CancellationToken token)
    {
        var tcs = new TaskCompletionSource<OneOf<T, UnexpectedError>>();
        var id = GetNewId();
            
        _runningRequests.Add(id, response =>
        {
            var res = ConvertToObject<T>(response);
            tcs.SetResult(res);
        });

        _webSocket.Send($"sub {id} {content}");
        _requestBodies.Add(id, content);

        while (!tcs.Task.IsCompleted)
            await Task.Delay(50, token);
            
        return await tcs.Task;
    }

    private void OnTradeRepublicMessage(object sender, MessageEventArgs e)
    {
        LogReceivedTradeRepublicMessage(e.Data);

        if (_isReconnect && e.Data == "connected")
        {
            _isReconnect = false;
                
            var runningRequestBodies = new Dictionary<int, string>(_requestBodies);
            foreach ((int requestId, string requestBody) in runningRequestBodies)
            {
                if (_runningRequestsAsync.ContainsKey(requestId))
                    _webSocket.Send($"sub {requestId} {requestBody}");
                else
                    _requestBodies.Remove(requestId);
            }
        }
            
        if (e.Data == "connected" || e.Data.StartsWith("echo"))
            return;

        if (DateTime.Now.Subtract(_lastMessageReceived).TotalSeconds > 30)
        {
            _webSocket.Send($"echo {_lastMessageReceived.Ticks}");
            _lastMessageReceived = DateTime.Now;
        }

        var id = ParseId(e.Data);

        if (id == -1)
            return;

        var message = GetMessageResponse(e.Data);

        if (_runningRequests.ContainsKey(id))
        {
            _webSocket.Send($"unsub {id}");

            _runningRequests[id].Invoke(message);
            _runningRequests.Remove(id);
        } else if (_runningRequestsAsync.ContainsKey(id))
        {
            var (type, productId) = _runningRequestsAsync[id];
            Task.Run(() => HandleRequestMessage(id, productId, type, message));
        }
    }

    private void LogReceivedTradeRepublicMessage(string message)
    {
        var logLevelForReceivedMessage = _isReconnect && message == "connected" ? LogEventLevel.Debug : LogEventLevel.Information;
            
        _logger.Write(logLevelForReceivedMessage, "{@TradeRepublicMessage}", new TradeRepublicMessage
        {
            Title = "Trade Republic api message",
            Content = message,
        });
    }
        
    private static string GetMessageResponse(string messageInput)
    {
        int index = messageInput.IndexOf('{') - 1;

        return index < 0 ? null : messageInput[index..];
    }
        
    private int ParseId(string message)
    {
        try
        {
            return int.Parse(message[..message.IndexOf(' ')]);
        }
        catch (Exception e)
        {
            _logger.Error(ApplicationConstants.LogMessageTemplate, new UnexpectedError
            {
                Title  = "Failed to parse id",
                Message = "Failed to parse id from trade republic message.",
                Exception = e,
                AdditionalData = new { message }
            });
            return -1;
        }
    }

    private int GetNewId() => ++_latestId;

    private async Task RegisterAllOngoingPosition()
    {
        try
        {
            var (ongoingWarrantPositions, ongoingKnockoutPositions) = _ongoingProductsService.GetAllOngoingPositions();

            var oneOfExchangeResults = new ConcurrentBag<Task<OneOf<TradeRepublicProductInfoDto, UnexpectedError>>>();
                
            string requestStr;
            foreach (var warrantPosition in ongoingWarrantPositions)
            {
                requestStr = "{\"type\":\"instrument\", \"id\":\"" + warrantPosition.Isin + "\"}";
                oneOfExchangeResults.Add(AddRequest<TradeRepublicProductInfoDto>(requestStr, CancellationToken.None));
            }
                
            foreach (var knockoutPosition in ongoingKnockoutPositions)
            {
                requestStr = "{\"type\":\"instrument\", \"id\":\"" + knockoutPosition.Isin + "\"}";
                oneOfExchangeResults.Add(AddRequest<TradeRepublicProductInfoDto>(requestStr, CancellationToken.None));
            }

            var results = await Task.WhenAll(oneOfExchangeResults);

            if (results.Any(r => r.IsT1))
            {
                _logger.Fatal(ApplicationConstants.LogMessageTemplate, results.First(r => r.IsT1).AsT1);
                Thread.Sleep(1000);
                Environment.Exit(-1);
            }

            var ids = results.Select(o => o.AsT0).ToList();

            foreach (var ongoingWarrantPosition in ongoingWarrantPositions)
            {
                var productInfo = ids.First(p => p.Isin == ongoingWarrantPosition.Isin);
                    
                if (productInfo.Active.HasValue && !productInfo.Active.Value)
                {
                    _logger.Information(
                        "Ongoing warrant with id {@Id} and isin {@Isin} is not active anymore and wont be added to ongoing requests",
                        ongoingWarrantPosition.Id, ongoingWarrantPosition.Isin);
                    continue;
                }
                    
                AddOngoingRequest(ongoingWarrantPosition.Isin + "." + productInfo.ExchangeIds.First(), PositionType.Warrant, ongoingWarrantPosition.Id);
            }

            foreach (var ongoingKnockoutPosition in ongoingKnockoutPositions)
            {
                var productInfo = ids.First(p => p.Isin == ongoingKnockoutPosition.Isin);
                    
                if (productInfo.Active.HasValue && !productInfo.Active.Value)
                {
                    _logger.Information(
                        "Ongoing knockout with id {@Id} and isin {@Isin} is not active anymore and wont be added to ongoing requests",
                        ongoingKnockoutPosition.Id, ongoingKnockoutPosition.Isin);
                    continue;
                }

                AddOngoingRequest(ongoingKnockoutPosition.Isin + "." + productInfo.ExchangeIds.First(), PositionType.Knockout, ongoingKnockoutPosition.Id);
            }
        }
        catch (Exception e)
        {
            _logger.Fatal(ApplicationConstants.LogMessageTemplate, new UnexpectedError
            {
                Title = "Failed register ongoing positions",
                Message = "Unexpected fatal error while trying to register ongoing positions",
                Exception = e,
            });
            Thread.Sleep(1000);
            Environment.Exit(-1);
        }
    }
        
    private void HandleRequestMessage(int id, int productId, PositionType positionType, string message)
    {
        if (ConvertToObject<TradeRepublicProductPriceResponseDto>(message).TryPickT0(out var value, out var err))
        {
            try
            {
                var result = GetOngoingTradeResponse(this, value, positionType, productId);

                switch (result)
                {
                    case OngoingTradeResponse.WaitingForFill:
                        break;
                    case OngoingTradeResponse.Complete:
                    case OngoingTradeResponse.PositionsAlreadyClosed:
                    case OngoingTradeResponse.Failed:
                        _webSocket.Send($"unsub {id}");
                        _runningRequestsAsync.Remove(id);
                        break;
                    default:
                        throw new ArgumentOutOfRangeException();
                }
            }
            catch (Exception e)
            {
                _logger.Error(ApplicationConstants.LogMessageTemplate, new UnexpectedError
                {
                    Title = "Processing ongoing trade failed",
                    Exception = e,
                    AdditionalData = new {Dto = value}
                });
                _webSocket.Send($"unsub {id}");
                _runningRequestsAsync.Remove(id);
            }
        }
        else
        {
            _logger.Error(ApplicationConstants.LogMessageTemplate, err);

            _webSocket.Send($"unsub {id}");
            _runningRequestsAsync.Remove(id);
        }
    }
        
    private OngoingTradeResponse GetOngoingTradeResponse(ITradeRepublicApi trService, TradeRepublicProductPriceResponseDto value, PositionType positionType, int productId)
    {
        return positionType switch
        {
            PositionType.Warrant => _ongoingProductsService.HandleOngoingWarrantTradeMessage(trService, value, positionType, productId),
            PositionType.Knockout => _ongoingProductsService.HandleOngoingKnockoutTradeMessage(trService, value, positionType, productId),
            PositionType.Stock => OngoingTradeResponse.Failed,
        };
    }
    
    private OneOf<T, UnexpectedError> ConvertToObject<T>(string content, JsonSerializerSettings jsonSerializerOptions = null)
    {
        jsonSerializerOptions ??= _jsonSerializerOptions;
            
        try
        {
            var result = JsonConvert.DeserializeObject<T>(content, jsonSerializerOptions);

            var isInvalidObject = result!.GetType().GetProperties()
                .Select(pi => pi.GetValue(result)).All(value => value is null);

            if (isInvalidObject)
                throw new Exception("All json properties were set null when trying to deserialize json string.");

            return result;
        }
        catch (Exception e)
        {
            return new UnexpectedError
            {
                Title = "Json parsing error",
                Message = "Parsing Trade Republic message response failed.",
                Exception = e,
                AdditionalData = new { Response = content, Type = typeof(T) },
            };
        }
    }
}