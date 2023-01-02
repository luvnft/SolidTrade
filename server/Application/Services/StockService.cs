using Application.Common.Interfaces.Persistence.Database;
using Application.Common.Interfaces.Services;
using Application.Common.Interfaces.Services.TradeRepublic;
using Application.Models.Dtos.Shared.Common;
using Application.Models.Dtos.Stock.Response;
using Application.Models.Dtos.TradeRepublic;
using AutoMapper;
using Domain.Entities;
using Domain.Enums;
using Microsoft.EntityFrameworkCore;
using Serilog;
using static Application.Common.Shared;

namespace Application.Services;

public class StockService : IStockService
{
    private readonly ILogger _logger = Log.ForContext<StockService>();
        
    private readonly ITradeRepublicApiService _trApiService;
    private readonly IUnitOfWork _unitOfWork;
    private readonly IMapper _mapper;

    public StockService(IUnitOfWork unitOfWork, IMapper mapper, ITradeRepublicApiService trApiService)
    {
        _trApiService = trApiService;
        _unitOfWork = unitOfWork;
        _mapper = mapper;
    }

    public async Task<Result<StockPositionResponseDto>> GetStock(int id, string uid)
    {
        var userResult = await _unitOfWork.Users
            .FirstAsync(u => u.Portfolio.StockPositions.Any(sp => sp.Id == id));

        if (userResult.TryTakeError(out var error, out var user))
            return error;

        if (!user.HasPublicPortfolio && uid != user.Uid)
            return NotAuthorized.PrivatePortfolio();

        var stockResult = await _unitOfWork.Stocks.FindByIdAsync(id);

        if (stockResult.TryTakeError(out error, out var stock))
            return error;

        _logger.Information("User with user uid {@Uid} fetched stock with stock id {@StockId} successfully", uid, id);

        return _mapper.Map<StockPositionResponseDto>(stock);
    }

    public async Task<Result<StockPositionResponseDto>> BuyStock(BuyOrSellRequestDto dto, string uid)
    {
        var result = await _trApiService.ValidateRequest(dto.Isin);

        if (result.TryPickT1(out var error, out _))
            return error;

        if ((await _trApiService.MakeTrRequest<TradeRepublicProductPriceResponseDto>(GetTradeRepublicProductPriceRequestString(dto.Isin))).TryPickT1(
                out error, out var trResponse))
            return error;

        var userResult = await _unitOfWork.Users
            .FirstAsync(u => u.Uid == uid, u => u.Portfolio);

        if (userResult.TryTakeError(out error, out var user))
            return error;
        
        var totalPrice = trResponse.Ask.Price * dto.NumberOfShares;

        if (totalPrice > user.Portfolio.Cash)
        {
            return new InsufficientFunds
            {
                Title = "Insufficient funds",
                Message = "User founds not sufficient for purchase.",
                UserFriendlyMessage = $"Balance insufficient. The total price is {totalPrice} but you have a balance of {user.Portfolio.Cash}",
                AdditionalData = new
                {
                    TotalPrice = totalPrice, UserBalance = user.Portfolio.Cash, Dto = dto,
                },
            };
        }
            
        var stock = new StockPosition
        {
            Isin = ToIsinWithoutExchangeExtension(dto.Isin),
            BuyInPrice = trResponse.Ask.Price,
            Portfolio = user.Portfolio,
            NumberOfShares = dto.NumberOfShares,
        };
            
        var historicalPositions = new HistoricalPosition
        {
            BuyOrSell = BuyOrSell.Buy,
            Isin = stock.Isin,
            Performance = -1,
            PositionType = PositionType.Stock,
            UserId = user.Id,
            BuyInPrice = trResponse.Ask.Price,
            NumberOfShares = dto.NumberOfShares,
        };

        var (isNew, newStock) = await AddOrUpdate(stock, user.Portfolio.Id);

        try
        {
            if (isNew)
                newStock = _unitOfWork.Stocks.Add(newStock).Entity;
            else
                newStock = _unitOfWork.Stocks.Update(newStock).Entity;

            user.Portfolio.Cash -= totalPrice;

            _unitOfWork.Portfolios.Update(user.Portfolio);
            _unitOfWork.HistoricalPositions.Add(historicalPositions);
                
            _logger.Information("Trying to save buy stock with isin {@Isin} for User with uid {@Uid}", dto.Isin, uid);
            await _unitOfWork.Commit();
            _logger.Information("Save buy stock with isin {@Isin} for User with uid {@Uid} was successful", dto.Isin, uid);
            return _mapper.Map<StockPositionResponseDto>(newStock);
        }
        catch (Exception e)
        {
            return new UnexpectedError
            {
                Title = "Could not buy position",
                Message = "Failed to buy position.",
                Exception = e,
                UserFriendlyMessage = "Something went very wrong. Please try again later.",
                AdditionalData = new { IsNew = isNew, Dto = dto, UserUid = uid, Message = "Maybe there was a problem with the isin?" },
            };
        }
    }
        
    public async Task<Result<StockPositionResponseDto>> SellStock(BuyOrSellRequestDto dto, string uid)
    {
        var result = await _trApiService.ValidateRequest(dto.Isin);

        if (result.TryPickT1(out var error, out _))
            return error;

        var isinWithoutExchangeExtension = ToIsinWithoutExchangeExtension(dto.Isin);

        if ((await _trApiService.MakeTrRequest<TradeRepublicProductPriceResponseDto>(GetTradeRepublicProductPriceRequestString(dto.Isin))).TryPickT1(
                out error, out var trResponse))
            return error;

        var totalGain = trResponse.Bid.Price * dto.NumberOfShares;

        var stockPositionResult = await _unitOfWork.Stocks
            .FirstAsync(s =>
                EF.Functions.Like(s.Isin, $"%{isinWithoutExchangeExtension}%")
                && s.Portfolio.User.Uid == uid, 
                s => s.Portfolio);

        if (stockPositionResult.TryTakeError(out error, out var stockPosition))
            return error;
        
        if (stockPosition.NumberOfShares < dto.NumberOfShares)
        {
            return new InvalidOrder
            {
                Title = "Sell failed",
                Message = "Can't sell more shares than existent",
                UserFriendlyMessage = "You can't sell more shares than you have.",
                AdditionalData = new { Dto = dto, Stock = _mapper.Map<StockPositionResponseDto>(stockPosition) }
            };
        }
            
        var performance = trResponse.Bid.Price / stockPosition.BuyInPrice;
            
        var historicalPositions = new HistoricalPosition
        {
            BuyOrSell = BuyOrSell.Sell,
            Isin = isinWithoutExchangeExtension,
            Performance = performance,
            PositionType = PositionType.Stock,
            UserId = stockPosition.Portfolio.UserId,
            BuyInPrice = trResponse.Bid.Price,
            NumberOfShares = dto.NumberOfShares,
        };

        try
        {
            stockPosition.Portfolio.Cash += totalGain;

            if (stockPosition.NumberOfShares == dto.NumberOfShares)
            {
                _unitOfWork.Stocks.Remove(stockPosition);
            }
            else
            {
                stockPosition.NumberOfShares -= dto.NumberOfShares;
                _unitOfWork.Stocks.Update(stockPosition);
            }

            _unitOfWork.Portfolios.Update(stockPosition.Portfolio);
            _unitOfWork.HistoricalPositions.Add(historicalPositions);
                
            _logger.Information("Trying to save sell stock with isin {@Isin} for User with uid {@Uid}", dto.Isin, uid);
            await _unitOfWork.Commit();
            _logger.Information("Save sell stock with isin {@Isin} for User with uid {@Uid} was successful", dto.Isin, uid);
            return _mapper.Map<StockPositionResponseDto>(stockPosition);
        }
        catch (Exception e)
        {
            return new UnexpectedError
            {
                Title = "Could not sell position",
                Message = "Failed to sell position.",
                Exception = e,
                UserFriendlyMessage = "Something went very wrong. Please try again later.",
                AdditionalData = new
                {
                    SoldAll = stockPosition.NumberOfShares == dto.NumberOfShares, Dto = dto, UserUid = uid,
                    Message = "Maybe there was a problem with the isin?"
                },
            };
        }
    }

    private async Task<(bool, StockPosition)> AddOrUpdate(StockPosition stockPosition, int portfolioId)
    {
        var stockResult = await _unitOfWork.Stocks
            .FirstAsync(s =>
                EF.Functions.Like(s.Isin, $"%{stockPosition.Isin}%") && portfolioId == s.Portfolio.Id);

        if (stockResult.TryTakeError(out _, out var stock))
            return (true, stockPosition);

        var position = CalculateNewPosition(stockPosition, stock);

        stock.BuyInPrice = position.BuyInPrice;
        stock.NumberOfShares = position.NumberOfShares;
            
        return (false, stock);
    }
}