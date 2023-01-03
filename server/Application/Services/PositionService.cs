using Application.Common;
using Application.Common.Interfaces.Persistence.Database;
using Application.Common.Interfaces.Services;
using Application.Extensions;
using Application.Models.Dtos.Position.Response;
using Application.Models.Dtos.Shared.Common;
using Application.Models.Dtos.TradeRepublic;
using Application.Services.TradeRepublic;
using AutoMapper;
using Domain.Entities;
using Domain.Enums;
using Microsoft.Extensions.Logging;

public class PositionService : IPositionService
{
    private readonly ILogger<PositionService> _logger;
    private readonly TradeRepublicApiService _trApiService;
    private readonly IUnitOfWork _unitOfWork;
    private readonly IMapper _mapper;

    public PositionService(IUnitOfWork unitOfWork, ILogger<PositionService> logger, IMapper mapper, TradeRepublicApiService trApiService)
    {
        _unitOfWork = unitOfWork;
        _trApiService = trApiService;
        _logger = logger;
        _mapper = mapper;
    }

    public async Task<Result<PositionResponseDto>> GetPositionAsync(int id, string uid)
    {
        var userQuery = await _unitOfWork.Users
            .FirstAsync(u => u.Portfolio.Positions.Any(p => p.Id == id));
        
        if (userQuery.TryTakeError(out var error, out var user))
            return error;

        if (!user.HasPublicPortfolio && uid != user.Uid)
            return NotAuthorized.PrivatePortfolio();

        var positionQuery = await _unitOfWork.Positions.FindByIdAsync(id);
        if (positionQuery.TryTakeError(out error, out var position))
            return error;

        _logger.LogInformation("User with user uid {@Uid} fetched position with id {@PositionId} successfully", uid, id);
        return _mapper.Map<PositionResponseDto>(position);
    }

    public async Task<Result<PositionResponseDto>> BuyPositionAsync(BuyOrSellRequestDto dto, string uid, PositionType type)
    {
        var productCanBeTradedQuery = await _trApiService.ValidateRequest(dto.Isin);
        if (productCanBeTradedQuery.TryTakeError(out var error, out _))
            return error;

        var productPriceQuery = await _trApiService
            .MakeTrRequest<TradeRepublicProductPriceResponseDto>(dto.Isin.ToTradeRepublic().ProductInfo());
        if (productPriceQuery.TryTakeError(out error, out var trResponse))
            return error;

        var userResult = await _unitOfWork.Users
            .FirstAsync(u => u.Uid == uid, u => u.Portfolio);
        if (userResult.TryTakeError(out error, out var user))
            return error;
        
        var totalPrice = trResponse.Ask.Price * dto.NumberOfShares;
        if (totalPrice > user.Portfolio.Cash)
            return InsufficientFunds.Default(totalPrice, user.Portfolio.Cash);

        var position = new Position
        {
            Isin = dto.Isin.ToTradeRepublic().IsinWithoutExchangeExtension(),
            BuyInPrice = trResponse.Ask.Price,
            Portfolio = user.Portfolio,
            NumberOfShares = dto.NumberOfShares,
        };
            
        var historicalPositions = new HistoricalPosition
        {
            BuyOrSell = BuyOrSell.Buy,
            Isin = position.Isin,
            Performance = -1,
            PositionType = type,
            UserId = user.Id,
            BuyInPrice = trResponse.Ask.Price,
            NumberOfShares = dto.NumberOfShares,
        };

        var positionExistQuery = await _unitOfWork.Positions.ShouldAddOrUpdatePositionAsync(position, user.Portfolio.Id);
        if (positionExistQuery.TryTakeError(out error, out var result))
            return error;

        var (positionAlreadyExists, exisingPosition) = result;

        if (positionAlreadyExists)
        {
            var (newNumberOfShares, newBuyInPrice) = Utilities.CalculateNewPosition(position, exisingPosition);
            
            position = exisingPosition;
            position.NumberOfShares = newNumberOfShares;
            position.BuyInPrice = newBuyInPrice;
        }
        
        user.Portfolio.Cash -= totalPrice;
        
        var positionEntry = _unitOfWork.Positions.AddOrUpdate(position);
        
        _unitOfWork.Portfolios.AddOrUpdate(user.Portfolio);
        _unitOfWork.HistoricalPositions.Add(historicalPositions);
            
        _logger.LogInformation("Trying to save buy position with isin {@Isin} for User with uid {@Uid}", dto.Isin, uid);
        var commitResult = await _unitOfWork.Commit();
        if (commitResult.TryTakeError(out error, out _))
            return error;
        
        _logger.LogInformation("Save buy position with isin {@Isin} for User with uid {@Uid} was successful", dto.Isin, uid);
        return _mapper.Map<PositionResponseDto>(positionEntry.Entity);
    }

    public async Task<Result<PositionResponseDto>> SellPositionAsync(BuyOrSellRequestDto dto, string uid,
        PositionType type)
    {
        var productCanBeTradedQuery = await _trApiService.ValidateRequest(dto.Isin);
        if (productCanBeTradedQuery.TryTakeError(out var error, out _))
            return error;

        var productPriceQuery = await _trApiService
            .MakeTrRequest<TradeRepublicProductPriceResponseDto>(dto.Isin.ToTradeRepublic().ProductInfo());
        if (productPriceQuery.TryTakeError(out error, out var trResponse))
            return error;

        var userResult = await _unitOfWork.Users
            .FirstAsync(u => u.Uid == uid, u => u.Portfolio);
        if (userResult.TryTakeError(out error, out var user))
            return error;

        var isinWithoutExchangeExtension = dto.Isin.ToTradeRepublic().IsinWithoutExchangeExtension();
        var positionQuery =
            await _unitOfWork.Positions.FindPositionAsync(isinWithoutExchangeExtension, user.Portfolio.Id);
        if (positionQuery.TryTakeError(out error, out var position))
            return error;

        if (position.NumberOfShares < dto.NumberOfShares)
        {
            return new InvalidOrder
            {
                Title = "Sell failed",
                Message = "Can't sell more shares than existent",
                UserFriendlyMessage = "You can't sell more shares than you have.",
                AdditionalData = new { Dto = dto, Stock = _mapper.Map<Position>(position) }
            };
        }

        var performance = trResponse.Bid.Price / position.BuyInPrice;

        var historicalPositions = new HistoricalPosition
        {
            BuyOrSell = BuyOrSell.Sell,
            Isin = isinWithoutExchangeExtension,
            Performance = performance,
            PositionType = type,
            UserId = user.Id,
            BuyInPrice = trResponse.Bid.Price,
            NumberOfShares = dto.NumberOfShares,
        };

        var totalPositionValue = trResponse.Ask.Price * dto.NumberOfShares;
        
        user.Portfolio.Cash += totalPositionValue;

        if (position.NumberOfShares == dto.NumberOfShares)
        {
            _unitOfWork.Positions.Remove(position);
        }
        else
        {
            position.NumberOfShares -= dto.NumberOfShares;
            _unitOfWork.Positions.AddOrUpdate(position);
        }

        _unitOfWork.Portfolios.AddOrUpdate(user.Portfolio);
        _unitOfWork.HistoricalPositions.Add(historicalPositions);
            
        _logger.LogInformation("Trying to save sell position with isin {@Isin} for User with uid {@Uid}", dto.Isin, uid);
        var commitResult = await _unitOfWork.Commit();
        if (commitResult.TryTakeError(out error, out _))
            return error;
        
        _logger.LogInformation("Save sell position with isin {@Isin} for User with uid {@Uid} was successful", dto.Isin, uid);
        return _mapper.Map<PositionResponseDto>(position);
    }
}