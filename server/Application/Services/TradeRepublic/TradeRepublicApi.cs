using System.Collections.Concurrent;
using Application.Common;
using Application.Common.Interfaces.Persistence.Database;
using Application.Common.Interfaces.Services;
using Application.Common.Interfaces.Services.Cache;
using Application.Common.Interfaces.Services.TradeRepublic;
using Application.Errors.Types;
using Application.Models.Dtos.TradeRepublic;
using Application.Models.Types;
using Domain.Entities;
using Domain.Enums;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
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
    private readonly Dictionary<int, int> _runningRequestsAsync = new();
    private readonly Dictionary<int, Action<string>> _runningRequests = new();
    private readonly Dictionary<int, string> _requestBodies = new();

    private readonly JsonSerializerSettings _jsonSerializerOptions;

    private readonly IServiceScopeFactory _scopeFactory;
    
    private readonly ILogger _logger = Log.ForContext<TradeRepublicApi>();
    private readonly WebSocket _webSocket;
    private bool _isReconnect;
        
    private DateTime _lastMessageReceived = DateTime.Now;
    private int _latestId;
        
    protected TradeRepublicApi(IConfiguration configuration, IServiceScopeFactory scopeFactory)
    {
        _scopeFactory = scopeFactory;
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
            Since there is no customizable way to fix this logging issue we turn off logging completely.
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
        
    public void AddStandingOrder(string isin, int entityId)
    {
        var id = GetNewId();
        _runningRequestsAsync.Add(id, entityId);

        var content = "{\"type\":\"ticker\",\"id\":\"" + isin + "\"}";
            
        _logger.Information("Add standing order with isin {@Isin} to trade republic API and wait for fill", isin);
        
        _webSocket.Send($"sub {id} {content}");
        _requestBodies.Add(id, content);
    }
        
    public async Task<Result<T>> AddRequest<T>(string content, CancellationToken token)
    {
        var tcs = new TaskCompletionSource<Result<T>>();
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
            var productId = _runningRequestsAsync[id];
            Task.Run(() => HandleRequestMessage(id, productId, message));
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
            _logger.Error(ApplicationConstants.LogMessageTemplate, new InvalidFormat
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
            Result<List<StandingOrder>> standingOrdersQuery; 
            using (var unitOfWork = _scopeFactory.CreateScope().ServiceProvider.GetRequiredService<IUnitOfWork>())
                standingOrdersQuery = await unitOfWork.StandingOrders.FindAllAsync();

            if (standingOrdersQuery.TryTakeError(out var error, out var standingOrders))
            {
                _logger.Error(ApplicationConstants.LogMessageTemplate, new UnexpectedError
                {
                    Title = "Failed to register all ongoing positions",
                    Message = "Unexpected fatal error while trying to register standing orders",
                    AdditionalData = new
                    {
                        Error = error
                    }
                });
                ExitDueToCriticalError();
                return;
            }

            var exchangeResults = new ConcurrentBag<Task<Result<TradeRepublicProductInfoDto>>>();

            var trRequestStrings =
                standingOrders.Select(order => "{\"type\":\"instrument\", \"id\":\"" + order.Isin + "\"}");
            foreach (var requestStr in trRequestStrings)
                // TODO: There should be a timeout for this request. We should not set the cancellation token to none.
                exchangeResults.Add(AddRequest<TradeRepublicProductInfoDto>(requestStr, CancellationToken.None));

            var results = await Task.WhenAll(exchangeResults);
            if (results.Any(r => r.IsFailure))
            {
                _logger.Fatal(ApplicationConstants.LogMessageTemplate, results.First(r => r.IsFailure).ErrorUnsafe);
                Thread.Sleep(1000);
                Environment.Exit(-1);
            }

            var ids = results.Select(r => r.ResultUnsafe).ToList();

            foreach (var order in standingOrders)
            {
                var productInfo = ids.First(p => p.Isin == order.Isin);
                if (productInfo.Active.HasValue && !productInfo.Active.Value)
                {
                    _logger.Information(
                        "Standing order with id {@Id} and isin {@Isin} is not active anymore and wont be added to ongoing requests",
                        order.Id, order.Isin);
                    continue;
                }

                var isinWithExchange = order.Isin + "." + productInfo.ExchangeIds.First();
                AddStandingOrder(isinWithExchange, order.Id);
            }
        }
        catch (Exception e)
        {
            _logger.Fatal(ApplicationConstants.LogMessageTemplate, new UnexpectedTradeRepublicRequestError
            {
                Title = "Failed to register standing orders",
                Message = "Unexpected fatal error while trying to register standing orders",
                Exception = e,
            });
            ExitDueToCriticalError();
        }
        
        void ExitDueToCriticalError()
        {
            Thread.Sleep(1000);
            Environment.Exit(-1);
        }
    }
        
    private async Task HandleRequestMessage(int id, int productId, string message)
    {
        if (ConvertToObject<TradeRepublicProductPriceResponseDto>(message).TryPickT0(out var value, out var err))
        {
            try
            {
                var standingOrderResponseResult = await HandleStandingOrderTradeMessage(value, productId);
                if (standingOrderResponseResult.TryTakeError(out var error, out var standingOrderStatus))
                {
                    _logger.Error("Something went wrong when trying to handle a standing order. {@Error}", error);
                    return;
                }
                
                switch (standingOrderStatus)
                {
                    case StandingOrderState.WaitingForFill:
                        break;
                    case StandingOrderState.Filled:
                    case StandingOrderState.Closed:
                    case StandingOrderState.Failed:
                        _webSocket.Send($"unsub {id}");
                        _runningRequestsAsync.Remove(id);
                        break;
                    default:
                        throw new ArgumentOutOfRangeException();
                }
            }
            catch (Exception e)
            {
                _logger.Error(ApplicationConstants.LogMessageTemplate, new UnexpectedTradeRepublicRequestError
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

    private async Task<Result<StandingOrderState>> HandleStandingOrderTradeMessage(TradeRepublicProductPriceResponseDto value,
        int standingOrderId)
    {
        var standingOrderService = _scopeFactory.CreateScope().ServiceProvider
            .GetRequiredService<IStandingOrderHandlerService>();
        return await standingOrderService.HandleStandingOrderTradeMessage(value, standingOrderId);
    }

    private Result<T> ConvertToObject<T>(string content, JsonSerializerSettings jsonSerializerOptions = null)
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
            return new InvalidFormat
            {
                Title = "Json parsing error",
                Message = "Parsing Trade Republic message response failed.",
                Exception = e,
                AdditionalData = new { Response = content, Type = typeof(T) },
            };
        }
    }
}