using Application.Common.Interfaces.Persistence;
using Application.Common.Interfaces.Persistence.Database;
using Application.Common.Interfaces.Services;
using Application.Common.Interfaces.Services.Cache;
using Application.Common.Interfaces.Services.TradeRepublic;
using Application.Errors;
using Application.Errors.Common;
using Application.Models.Dtos.TradeRepublic;
using Domain.Entities;
using Domain.Enums;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using OneOf;
using Serilog;
using static Application.Common.Shared;
using static Application.Common.ApplicationConstants;

namespace Application.Services;

public class OngoingProductsService : IOngoingProductsService
{
    private static readonly ILogger Logger = Log.ForContext<OngoingProductsService>();
    private readonly INotificationService _notificationService;
    private readonly IServiceScopeFactory _scopeFactory;
    private readonly ICacheService _cache;

    public OngoingProductsService(INotificationService notificationService, ICacheService cache, IServiceScopeFactory scopeFactory)
    {
        _notificationService = notificationService;
        _scopeFactory = scopeFactory;
        _cache = cache;
    }
        
    public (List<OngoingWarrantPosition>, List<OngoingKnockoutPosition>) GetAllOngoingPositions()
    {
        using var db = _scopeFactory.CreateScope().ServiceProvider.GetRequiredService<IApplicationDbContext>();
        return (db.OngoingWarrantPositions.ToList(), db.OngoingKnockoutPositions.ToList());
    }

    public OngoingTradeResponse HandleOngoingWarrantTradeMessage(ITradeRepublicApi trService, 
        TradeRepublicProductPriceResponseDto trMessage, PositionType type, int ongoingProductId)
    {
        var cachedWarrant = _cache.GetCachedValue<OngoingWarrantPosition>(ongoingProductId.ToString());
        
        OngoingWarrantPosition ongoingProduct;
        if (cachedWarrant.Expired)
        {
            using (var db = _scopeFactory.CreateScope().ServiceProvider.GetRequiredService<IApplicationDbContext>())
            {
                ongoingProduct = db.OngoingWarrantPositions.Find(ongoingProductId);
            }

            _cache.SetCachedValue(ongoingProduct.Id.ToString(), ongoingProduct);
        }
        else
        {
            ongoingProduct = cachedWarrant.Value;
        }
            
        if (ongoingProduct is null || DateTimeOffset.Now > ongoingProduct.GoodUntil)
            return OngoingTradeResponse.PositionsAlreadyClosed;
            
        decimal price;
        var isBuyOrSell = IsBuyOrSell(ongoingProduct.Type);
            
        if (isBuyOrSell == BuyOrSell.Buy)
            price = Math.Min(trMessage.Ask.Price, ongoingProduct.Price);
        else
            price = Math.Max(trMessage.Bid.Price, ongoingProduct.Price);
            
        var isFulfilled = GetOngoingProductHandler(ongoingProduct.Type, trMessage, ongoingProduct.Price);
        
        if (!isFulfilled)
            return OngoingTradeResponse.WaitingForFill;
        
        OneOf<TradeRepublicProductInfoDto, ErrorResponse> oneOfResult;

        try
        {
            oneOfResult = MakeTrRequestWithService<TradeRepublicProductInfoDto>(trService, 
                GetTradeRepublicProductInfoRequestString(ongoingProduct.Isin)).GetAwaiter().GetResult();
        }
        catch (Exception e)
        {
            Logger.Error(LogMessageTemplate, new UnexpectedError
            {
                Title = "Unable to make Trade Republic request",
                Message = "Unexpect error when trying to make trade republic request.",
                AdditionalData = new { Isin = ongoingProduct.Isin },
                Exception = e,
            });
            return OngoingTradeResponse.WaitingForFill;
        }
            
        if (oneOfResult.TryPickT1(out var errorResponse, out var isActiveResponse))
        {
            Logger.Error(LogMessageTemplate, errorResponse);
            return OngoingTradeResponse.WaitingForFill;
        }

        if (!isActiveResponse.Active!.Value)
        {
            // Todo: Notify user.
            const string message = "Ongoing product can not be bought or sold. This might happen if the product is expired or is knocked out.";
            var err = new TradeFailed
            {
                Title = "Product can not be traded",
                Message = message,
                UserFriendlyMessage = message,
                AdditionalData = new { Dto = ongoingProduct.Isin }
            };
            Logger.Error(LogMessageTemplate, err);
            return OngoingTradeResponse.Failed;
        }
            
        try
        {
            using var database = _scopeFactory.CreateScope().ServiceProvider.GetRequiredService<IApplicationDbContext>();
                
            ongoingProduct = database.OngoingWarrantPositions
                .Include(p => p.Portfolio)
                .FirstOrDefault(p => p.Id == ongoingProductId);
        
            // Double check if the ongoing product is not already closed by the user. There is a chance that the cached value is not in the database anymore.
            if (ongoingProduct is null)
                // Product is already closed by the user.
                return OngoingTradeResponse.PositionsAlreadyClosed;
                
            var totalPrice = ongoingProduct.NumberOfShares * price;
            HistoricalPosition historicalPosition;
                
            if (isBuyOrSell is BuyOrSell.Buy)
            {
                if (totalPrice > ongoingProduct.Portfolio.Cash)
                {
                    var message =
                        $"User ongoing product was satisfied but had not sufficient founds. User balance: {ongoingProduct.Portfolio.Cash} but required capital is: {totalPrice}.";
                        
                    _notificationService.SendNotification(ongoingProduct.Portfolio.UserId, "", "Position could not be filled",
                        $"Your {GetOrderName(ongoingProduct.Type)} order could not be executed. {message}");

                    database.OngoingWarrantPositions.Remove(ongoingProduct);
                        
                    Logger.Warning(LogMessageTemplate, new InsufficientFounds
                    {
                        Title = "Not enough buying power",
                        Message = message,
                        AdditionalData = new { ProductId = ongoingProductId, Type = type, },
                    });

                    database.SaveChanges();
                    return OngoingTradeResponse.Failed;
                }
                    
                var existingWarrantPosition = database.WarrantPositions
                    .AsQueryable()
                    .FirstOrDefault(w => w.Isin == ongoingProduct.Isin && w.Portfolio.Id == ongoingProduct.Portfolio.Id);

                var warrantPosition = existingWarrantPosition;
                if (existingWarrantPosition is not null)
                {
                    var position = CalculateNewPosition(existingWarrantPosition, new WarrantPosition
                    {
                        NumberOfShares = ongoingProduct.NumberOfShares, BuyInPrice = price,
                    });

                    warrantPosition.BuyInPrice = position.BuyInPrice;
                    warrantPosition.NumberOfShares = position.NumberOfShares;

                    database.WarrantPositions.Update(warrantPosition);
                }
                else
                {
                    warrantPosition = new WarrantPosition
                    {
                        Isin = ongoingProduct.Isin,
                        Portfolio = ongoingProduct.Portfolio,
                        BuyInPrice = price,
                        NumberOfShares = ongoingProduct.NumberOfShares,
                    };
                        
                    database.WarrantPositions.Add(warrantPosition);
                }
                    
                historicalPosition = new HistoricalPosition
                {
                    BuyOrSell = isBuyOrSell,
                    Isin = ongoingProduct.Isin,
                    Performance = -1,
                    PositionType = PositionType.Warrant,
                    UserId = ongoingProduct.Portfolio.UserId,
                    BuyInPrice = price,
                    NumberOfShares = ongoingProduct.NumberOfShares,
                };
            }
            else
            {
                var existingWarrantPosition = database.WarrantPositions
                    .AsQueryable()
                    .FirstOrDefault(w => w.Isin == ongoingProduct.Isin && w.Portfolio.Id == ongoingProduct.Portfolio.Id);

                var warrantPosition = existingWarrantPosition;
                if (warrantPosition is null || warrantPosition.NumberOfShares < ongoingProduct.NumberOfShares)
                {
                    var orderName = $"{GetOrderName(ongoingProduct.Type)} order";
                    const string message = "Order not executed because warrant does not exist anymore or the number of shares are less then the tried to sell.";

                    _notificationService.SendNotification(ongoingProduct.Portfolio.UserId, "", "Position could not be filled",
                        $"Your {orderName} could not be executed. {message}");
                        
                    Logger.Warning(LogMessageTemplate, new UnexpectedError
                    {
                        Title = "Could not fill position",
                        Message = message,
                    });
                        
                    database.OngoingWarrantPositions.Remove(ongoingProduct);
                    database.SaveChanges();
                    return OngoingTradeResponse.Failed;
                }
                    
                warrantPosition.NumberOfShares -= ongoingProduct.NumberOfShares;
                    
                historicalPosition = new HistoricalPosition
                {
                    BuyOrSell = isBuyOrSell,
                    Isin = ongoingProduct.Isin,
                    Performance = price / warrantPosition.BuyInPrice,
                    PositionType = PositionType.Warrant,
                    UserId = ongoingProduct.Portfolio.UserId,
                    BuyInPrice = price,
                    NumberOfShares = ongoingProduct.NumberOfShares,
                };
                    
                if (warrantPosition.NumberOfShares == 0)
                    database.WarrantPositions.Remove(warrantPosition);
                else
                    database.WarrantPositions.Update(warrantPosition);
            }

            database.OngoingWarrantPositions.Remove(ongoingProduct);
                
            _notificationService.SendNotification(ongoingProduct.Portfolio.UserId, "", "Position filled", $"Your {GetOrderName(ongoingProduct.Type)} order was executed.");

            if (isBuyOrSell is BuyOrSell.Buy)
                ongoingProduct.Portfolio.Cash -= totalPrice;
            else 
                ongoingProduct.Portfolio.Cash += totalPrice;

            database.Portfolios.Update(ongoingProduct.Portfolio);
            database.HistoricalPositions.Add(historicalPosition);
                
            database.SaveChanges();
            return OngoingTradeResponse.Complete;
        }
        catch (Exception e)
        {
            Logger.Error(LogMessageTemplate, new UnexpectedError
            {
                Title = "Ongoing trade update failed",
                Message = "Failed to process fill of ongoing trade",
                Exception = e,
                AdditionalData = new
                {
                    TradeRepublicMessage = trMessage,
                    OngoingProductId = ongoingProductId,
                    Type = type,
                },
            });
            return OngoingTradeResponse.Failed;
        }
    }

    public OngoingTradeResponse HandleOngoingKnockoutTradeMessage(ITradeRepublicApi trService, 
        TradeRepublicProductPriceResponseDto trMessage, PositionType type, int ongoingProductId)
    {
        var cachedKnockout = _cache.GetCachedValue<OngoingKnockoutPosition>(ongoingProductId.ToString());
        
        OngoingKnockoutPosition ongoingProduct;
        if (cachedKnockout.Expired)
        {
            using (var db = _scopeFactory.CreateScope().ServiceProvider.GetRequiredService<IApplicationDbContext>())
            {
                ongoingProduct = db.OngoingKnockoutPositions.Find(ongoingProductId);
            }

            _cache.SetCachedValue(ongoingProduct.Id.ToString(), ongoingProduct);
        }
        else
        {
            ongoingProduct = cachedKnockout.Value;
        }
            
        if (ongoingProduct is null || DateTimeOffset.Now > ongoingProduct.GoodUntil)
            return OngoingTradeResponse.PositionsAlreadyClosed;
            
        decimal price;
        var isBuyOrSell = IsBuyOrSell(ongoingProduct.Type);
            
        if (isBuyOrSell == BuyOrSell.Buy)
            price = Math.Min(trMessage.Ask.Price, ongoingProduct.Price);
        else
            price = Math.Max(trMessage.Bid.Price, ongoingProduct.Price);
            
        var isFulfilled = GetOngoingProductHandler(ongoingProduct.Type, trMessage, ongoingProduct.Price);
        
        if (!isFulfilled)
            return OngoingTradeResponse.WaitingForFill;
        
        try
        {
            using var database = _scopeFactory.CreateScope().ServiceProvider.GetRequiredService<IApplicationDbContext>();
                
            ongoingProduct = database.OngoingKnockoutPositions
                .Include(p => p.Portfolio)
                .FirstOrDefault(p => p.Id == ongoingProductId);
        
            // Double check if the ongoing product is not already closed by the user. There is a chance that the cached value is not in the database anymore.
            if (ongoingProduct is null)
                // Product is already closed by the user.
                return OngoingTradeResponse.PositionsAlreadyClosed;

            OneOf<TradeRepublicProductInfoDto, ErrorResponse> oneOfResult;

            try
            {
                oneOfResult = MakeTrRequestWithService<TradeRepublicProductInfoDto>(trService,
                    GetTradeRepublicProductInfoRequestString(ongoingProduct.Isin)).GetAwaiter().GetResult();
            }
            catch (Exception e)
            {
                Logger.Error(LogMessageTemplate, new UnexpectedError
                {
                    Title = "Unable to make Trade Republic request",
                    Message = "Unexpect error when trying to make trade republic request.",
                    AdditionalData = new { Isin = ongoingProduct.Isin },
                    Exception = e,
                });
                return OngoingTradeResponse.WaitingForFill;
            }

            if (oneOfResult.TryPickT1(out var errorResponse, out var isActiveResponse))
            {
                Logger.Error(LogMessageTemplate, errorResponse);
                return OngoingTradeResponse.WaitingForFill;
            }

            if (!isActiveResponse.Active!.Value)
            {
                // Todo: Notify user.
                const string message = "Ongoing product can not be bought or sold. This might happen if the product is expired or is knocked out.";
                var err = new TradeFailed
                {
                    Title = "Product can not be traded",
                    Message = message,
                    UserFriendlyMessage = message,
                    AdditionalData = new { Dto = ongoingProduct.Isin }
                };
                Logger.Error(LogMessageTemplate, err);
                return OngoingTradeResponse.Failed;
            }
                
            var totalPrice = ongoingProduct.NumberOfShares * price;

            HistoricalPosition historicalPosition;
            if (isBuyOrSell is BuyOrSell.Buy)
            {
                if (totalPrice > ongoingProduct.Portfolio.Cash)
                {
                    var message =
                        $"User ongoing product was satisfied but had not sufficient founds. User balance: {ongoingProduct.Portfolio.Cash} but required capital is: {totalPrice}.";
                        
                    _notificationService.SendNotification(ongoingProduct.Portfolio.UserId, "", "Position could not be filled",
                        $"Your {GetOrderName(ongoingProduct.Type)} order could not be executed. {message}");

                    database.OngoingKnockoutPositions.Remove(ongoingProduct);
                        
                    Logger.Warning(LogMessageTemplate, new InsufficientFounds
                    {
                        Title = "Not enough buying power",
                        Message = message,
                        AdditionalData = new { ProductId = ongoingProductId, Type = type, },
                    });

                    database.SaveChanges();
                    return OngoingTradeResponse.Failed;
                }
                    
                var existingKnockoutPosition = database.KnockoutPositions
                    .AsQueryable()
                    .FirstOrDefault(w => w.Isin == ongoingProduct.Isin && w.Portfolio.Id == ongoingProduct.Portfolio.Id);

                var knockoutPosition = existingKnockoutPosition;
                if (knockoutPosition is not null)
                {
                    var position = CalculateNewPosition(existingKnockoutPosition, new KnockoutPosition
                    {
                        NumberOfShares = ongoingProduct.NumberOfShares, BuyInPrice = price,
                    });

                    knockoutPosition.BuyInPrice = position.BuyInPrice;
                    knockoutPosition.NumberOfShares = position.NumberOfShares;

                    database.KnockoutPositions.Update(knockoutPosition);
                }
                else
                {
                    knockoutPosition = new KnockoutPosition
                    {
                        Isin = ongoingProduct.Isin,
                        Portfolio = ongoingProduct.Portfolio,
                        BuyInPrice = price,
                        NumberOfShares = ongoingProduct.NumberOfShares,
                    };
                        
                    database.KnockoutPositions.Add(knockoutPosition);
                }
                    
                historicalPosition = new HistoricalPosition
                {
                    BuyOrSell = isBuyOrSell,
                    Isin = ongoingProduct.Isin,
                    Performance = -1,
                    PositionType = PositionType.Knockout,
                    UserId = ongoingProduct.Portfolio.UserId,
                    BuyInPrice = price,
                    NumberOfShares = ongoingProduct.NumberOfShares,
                };
            }
            else
            {
                var existingKnockoutPosition = database.KnockoutPositions
                    .AsQueryable()
                    .FirstOrDefault(w => w.Isin == ongoingProduct.Isin && w.Portfolio.Id == ongoingProduct.Portfolio.Id);

                var knockoutPosition = existingKnockoutPosition;
                if (knockoutPosition is null || knockoutPosition.NumberOfShares < ongoingProduct.NumberOfShares)
                {
                    var orderName = $"{GetOrderName(ongoingProduct.Type)} order";
                    const string message = "Order not executed because knockout does not exist anymore or the number of shares are less then the tried to sell.";

                    _notificationService.SendNotification(ongoingProduct.Portfolio.UserId, "", "Position could not be filled",
                        $"Your {orderName} could not be executed. {message}");
                        
                    Logger.Warning(LogMessageTemplate, new UnexpectedError
                    {
                        Title = "Could not fill position",
                        Message = message,
                    });
                        
                    database.OngoingKnockoutPositions.Remove(ongoingProduct);
                    database.SaveChanges();
                    return OngoingTradeResponse.Failed;
                }
                    
                knockoutPosition.NumberOfShares -= ongoingProduct.NumberOfShares;
                    
                historicalPosition = new HistoricalPosition
                {
                    BuyOrSell = isBuyOrSell,
                    Isin = ongoingProduct.Isin,
                    Performance = price / knockoutPosition.BuyInPrice,
                    PositionType = PositionType.Knockout,
                    UserId = ongoingProduct.Portfolio.UserId,
                    BuyInPrice = price,
                    NumberOfShares = ongoingProduct.NumberOfShares,
                };

                if (knockoutPosition.NumberOfShares == 0)
                    database.KnockoutPositions.Remove(knockoutPosition);
                else
                    database.KnockoutPositions.Update(knockoutPosition);
            }

            database.OngoingKnockoutPositions.Remove(ongoingProduct);
                
            _notificationService.SendNotification(ongoingProduct.Portfolio.UserId, "", "Position filled", $"Your {GetOrderName(ongoingProduct.Type)} order was executed.");

            if (isBuyOrSell is BuyOrSell.Buy)
                ongoingProduct.Portfolio.Cash -= totalPrice;
            else 
                ongoingProduct.Portfolio.Cash += totalPrice;

            database.Portfolios.Update(ongoingProduct.Portfolio);
            database.HistoricalPositions.Add(historicalPosition);
                
            database.SaveChanges();
            return OngoingTradeResponse.Complete;
        }
        catch (Exception e)
        {
            Logger.Error(LogMessageTemplate, new UnexpectedError
            {
                Title = "Ongoing trade update failed",
                Message = "Failed to process fill of ongoing trade",
                Exception = e,
                AdditionalData = new
                {
                    TradeRepublicMessage = trMessage,
                    OngoingProductId = ongoingProductId,
                    Type = type,
                },
            });
            return OngoingTradeResponse.Failed;
        }
    }
}