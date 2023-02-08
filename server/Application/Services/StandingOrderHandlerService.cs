using Application.Common;
using Application.Common.Interfaces.Persistence.Database;
using Application.Common.Interfaces.Services;
using Application.Common.Interfaces.Services.Cache;
using Application.Common.Interfaces.Services.TradeRepublic;
using Application.Extensions;
using Application.Models.Dtos.TradeRepublic;
using Domain.Entities;
using Domain.Enums;
using Microsoft.Extensions.Logging;
using static Application.Common.ApplicationConstants;

namespace Application.Services;

public class StandingOrderHandlerService : IStandingOrderHandlerService
{
    private readonly ILogger<StandingOrderHandlerService> _logger;
    private readonly INotificationService _notificationService;
    private readonly ITradeRepublicApiService _trApiService;
    private readonly IUnitOfWork _unitOfWork;
    private readonly ICacheService _cache;

    public StandingOrderHandlerService(
        INotificationService notificationService,
        ICacheService cache,
        ILogger<StandingOrderHandlerService> logger,
        IUnitOfWork unitOfWork,
        ITradeRepublicApiService trApiService)
    {
        _notificationService = notificationService;
        _logger = logger;
        _unitOfWork = unitOfWork;
        _trApiService = trApiService;
        _cache = cache;
    }
    
    public async Task<Result<StandingOrderState>> HandleStandingOrderTradeMessage(TradeRepublicProductPriceResponseDto dto, int standingOrderId)
    {
        var cachedOrder = _cache.GetCachedValue<StandingOrder>(standingOrderId.ToString());

        StandingOrder standingOrder;
        if (cachedOrder.Expired)
        {
            var orderQuery = await _unitOfWork.StandingOrders.FindByIdAsync(standingOrderId);
            if (orderQuery.TryTakeError(out var err, out standingOrder))
                return err;
            
            _cache.SetCachedValue(standingOrder.Id.ToString(), standingOrder);
        }
        else
        {
            standingOrder = cachedOrder.Value;
        }

        if (DateTimeOffset.Now > standingOrder.GoodUntil)
            return StandingOrderState.Closed;

        var isFulfilled = standingOrder.OrderType.IsOrderFulfilled(dto, standingOrder.Price);
        if (!isFulfilled)
            return StandingOrderState.WaitingForFill;
        
        var buyOrSellPrice = standingOrder.OrderType.IsBuyOrSell() == BuyOrSell.Buy
            ? Math.Min(dto.Ask.Price, standingOrder.Price)
            : Math.Max(dto.Bid.Price, standingOrder.Price);

        var standingOrderQuery = await _unitOfWork.StandingOrders
            .FirstAsync(s => s.Id == standingOrderId, s => s.Portfolio);

        // Double check if the ongoing product is not already closed by the user. There is a chance that the cached value is not in the database anymore.
        if (standingOrderQuery.TryTakeError(out var error, out standingOrder))
        {
            if (error is EntityNotFound)
                // Product is already closed by the user.
                return StandingOrderState.Closed;

            return error;
        }

        var productCanBeTradedQuery = await _trApiService
            .ValidateRequest(standingOrder.Isin.ToTradeRepublic().IsinWithoutExchangeExtension());
        if (productCanBeTradedQuery.TryTakeError(out error, out _))
        {
            if (error is InvalidOrder)
                // The product can not be bought or sold. This might happen if the product is expired or is knocked out.
                return StandingOrderState.Closed;

            return error;
        }
        
        return standingOrder.OrderType.IsBuyOrSell() == BuyOrSell.Buy
            ? await BuyIntoPosition(standingOrder, buyOrSellPrice)
            : await SellPosition(standingOrder, buyOrSellPrice);
    }

    // TODO: Fix Sending notifications to user (missing registration token).
    
    private async Task<Result<StandingOrderState>> BuyIntoPosition(StandingOrder standingOrder, decimal buyPrice)
    {
        var totalPrice = standingOrder.NumberOfShares * buyPrice;
        
        if (standingOrder.Portfolio.Cash < totalPrice)
        {
            var userFriendlyMessage = 
                "Your buy order could not be executed because you there was not have enough cash. " +
                $"Your balance: {standingOrder.Portfolio.Cash} but required capital was: {totalPrice}. Please deposit more cash to your account.";

            var insufficientFundsError = new InsufficientFunds
            {
                Title = "Insufficient funds",
                Message = "Insufficient funds for executing standing buy order",
                UserFriendlyMessage = userFriendlyMessage,
                AdditionalData = new
                {
                    
                    PortfolioId = standingOrder.Portfolio.Id,
                    CashAvailable = standingOrder.Portfolio.Cash,
                    CashRequired = totalPrice,
                },
            };

            FireAndForget(() => _notificationService.SendNotification(standingOrder.Portfolio.UserId, "",
                "Position could not be filled", userFriendlyMessage));
            _logger.LogWarning(LogMessageTemplate, insufficientFundsError);
            
            _logger.LogInformation("Removing standing order with id of {@Id} because of insufficient funds", standingOrder.Id);
            
            _unitOfWork.StandingOrders.Remove(standingOrder);
            var commitResult = await _unitOfWork.Commit();
            if (commitResult.TryTakeError(out var e, out _))
                return e;

            _logger.LogInformation("Removing standing order with id of {@Id} was successful", standingOrder.Id);
            return StandingOrderState.Closed;
        }
        
        var positionAlreadyExistsQuery = await _unitOfWork.Positions.ShouldAddOrUpdatePositionAsync(standingOrder.Isin, standingOrder.Portfolio.Id);
        if (positionAlreadyExistsQuery.TryTakeError(out var error, out var positionAlreadyExistResult))
            return error;
        
        var (positionAlreadyExists, exisingPosition) = positionAlreadyExistResult;

        Position positionToBeAddedOrUpdated;
        if (positionAlreadyExists)
        {
            var (numberOfShares, buyInPrice) = Utilities.CalculateNewPosition(exisingPosition, new Position
            {
                NumberOfShares = standingOrder.NumberOfShares,
                BuyInPrice = buyPrice,
            });

            exisingPosition.BuyInPrice = buyInPrice;
            exisingPosition.NumberOfShares = numberOfShares;
            positionToBeAddedOrUpdated = exisingPosition;
            _unitOfWork.Positions.AddOrUpdate(positionToBeAddedOrUpdated);
        }
        else
        {
            positionToBeAddedOrUpdated = new Position
            {
                Isin = standingOrder.Isin,
                Portfolio = standingOrder.Portfolio,
                BuyInPrice = buyPrice,
                NumberOfShares = standingOrder.NumberOfShares,
                Type = standingOrder.PositionType,
            };

            _unitOfWork.Positions.Add(positionToBeAddedOrUpdated); 
        }

        var historicalPosition = new HistoricalPosition
        {
            BuyOrSell = BuyOrSell.Buy,
            Isin = standingOrder.Isin,
            Performance = -1,
            PositionType = standingOrder.PositionType,
            UserId = standingOrder.Portfolio.UserId,
            BuyInPrice = buyPrice,
            NumberOfShares = standingOrder.NumberOfShares,
        };

        return await CompleteOrder(standingOrder, historicalPosition, totalPrice);
    }

    private async Task<Result<StandingOrderState>> SellPosition(StandingOrder standingOrder, decimal sellPrice)
    {
        var totalPrice = sellPrice * standingOrder.NumberOfShares;
            
        var positionAlreadyExistsQuery = await _unitOfWork.Positions.ShouldAddOrUpdatePositionAsync(standingOrder.Isin, standingOrder.Portfolio.Id);
        if (positionAlreadyExistsQuery.TryTakeError(out var error, out var positionAlreadyExistResult))
            return error;
        
        var (positionAlreadyExists, exisingPosition) = positionAlreadyExistResult; 
        if (!positionAlreadyExists || exisingPosition.NumberOfShares < standingOrder.NumberOfShares)
        {
            var userFriendlyMessage =
                "Your sell order could not be executed because you do not have enough shares. " +
                $"You have {exisingPosition?.NumberOfShares ?? 0} shares but the sell order is supposed to sell {standingOrder.NumberOfShares} shares."; 

            FireAndForget(() => _notificationService.SendNotification(standingOrder.Portfolio.UserId, "",
                "Sell order could not be executed", userFriendlyMessage));

            _logger.LogWarning(LogMessageTemplate, new InvalidOrder
            {
                Title = "Could not executed sell order",
                Message = "Could not executed sell order because there were not enough shares",
                UserFriendlyMessage = userFriendlyMessage,
                AdditionalData = new
                {
                    PortfolioId = standingOrder.Portfolio.Id,
                    StandingOrderId = standingOrder.Id,
                }
            });

            _logger.LogInformation("Removing standing order with id of {@Id} because of insufficient funds", standingOrder.Id);
            
            _unitOfWork.StandingOrders.Remove(standingOrder);
            var commitResult = await _unitOfWork.Commit();
            if (commitResult.TryTakeError(out error, out _))
                return error;

            _logger.LogInformation("Removing standing order with id of {@Id} was successful", standingOrder.Id);
            return StandingOrderState.Failed;
        }

        exisingPosition.NumberOfShares -= standingOrder.NumberOfShares;

        var historicalPosition = new HistoricalPosition
        {
            BuyOrSell = BuyOrSell.Sell,
            Isin = standingOrder.Isin,
            Performance = sellPrice / exisingPosition.BuyInPrice,
            PositionType = standingOrder.PositionType,
            UserId = standingOrder.Portfolio.UserId,
            BuyInPrice = sellPrice,
            NumberOfShares = standingOrder.NumberOfShares,
        };

        if (exisingPosition.NumberOfShares == 0)
            _unitOfWork.Positions.Remove(exisingPosition);
        else
            _unitOfWork.Positions.AddOrUpdate(exisingPosition);

        return await CompleteOrder(standingOrder, historicalPosition, totalPrice);
    }
    
    private async Task<Result<StandingOrderState>> CompleteOrder(StandingOrder standingOrder, HistoricalPosition historicalPosition, decimal totalPrice)
    {
        _unitOfWork.StandingOrders.Remove(standingOrder);

        FireAndForget(() => 
            _notificationService
                .SendNotification(standingOrder.Portfolio.UserId, "", "Position filled",
                    $"Your {standingOrder.OrderType.UserFriendlyFullName()} order was executed successfully."));

        if (historicalPosition.BuyOrSell is BuyOrSell.Buy)
            standingOrder.Portfolio.Cash -= totalPrice;
        else
            standingOrder.Portfolio.Cash += totalPrice;

        _unitOfWork.Portfolios.AddOrUpdate(standingOrder.Portfolio);
        _unitOfWork.HistoricalPositions.Add(historicalPosition);

        var commitResult = await _unitOfWork.Commit();
        if (commitResult.TryTakeError(out var error, out _))
            return error;
        
        return StandingOrderState.Filled;
    }

    private static void FireAndForget(Action action) => Task.Run(action);
}