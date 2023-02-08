using Application.Common.Interfaces.Persistence.Database;
using Application.Common.Interfaces.Services;
using Application.Common.Interfaces.Services.TradeRepublic;
using Application.Extensions;
using Application.Models.Dtos.StandingOrder.Request;
using Application.Models.Dtos.StandingOrder.Response;
using Application.Models.Dtos.TradeRepublic;
using AutoMapper;
using Domain.Entities;
using Microsoft.Extensions.Logging;

namespace Application.Services;

public class StandingOrderService : IStandingOrderService
{
    private readonly ILogger<StandingOrderService> _logger;
    private readonly ITradeRepublicApiService _trApiService;
    private readonly IUnitOfWork _unitOfWork;
    private readonly IMapper _mapper;

    public StandingOrderService(ITradeRepublicApiService trApiService, ILogger<StandingOrderService> logger, IUnitOfWork unitOfWork, IMapper mapper)
    {
        _trApiService = trApiService;
        _unitOfWork = unitOfWork;
        _logger = logger;
        _mapper = mapper;
    }

    public async Task<Result<StandingOrderResponseDto>> GetStandingOrder(int id, string uid)
    {
        var userQuery = await _unitOfWork.Users
            .FirstAsync(u => u.Portfolio.StandingOrders.Any(s => s.Id == id));

        if (userQuery.TryTakeError(out var error, out var user))
            return error;
        
        if (!user.HasPublicPortfolio && uid != user.Uid)
            return NotAuthorized.PrivatePortfolio();

        var standingOrderQuery = await _unitOfWork.StandingOrders.FindByIdAsync(id);

        if (standingOrderQuery.TryTakeError(out error, out var standingOrder))
            return error;
        
        _logger.LogInformation("User with user uid {@Uid} fetched standing order with id {@StandingOrderId} successfully", uid, id);

        return _mapper.Map<StandingOrderResponseDto>(standingOrder);
    }

    public async Task<Result<StandingOrderResponseDto>> CreateStandingOrder(CreateStandingOrderRequestDto dto, string uid)
    {
        var productCanBeTradedQuery = await _trApiService.ValidateRequest(dto.Isin);
        if (productCanBeTradedQuery.TryTakeError(out var error, out _))
            return error;

        var productPriceQuery = await _trApiService
            .MakeTrRequest<TradeRepublicProductPriceResponseDto>(dto.Isin.ToTradeRepublic().ProductPrice());
        if (productPriceQuery.TryTakeError(out error, out var trResponse))
            return error;

        var isinWithoutExchangeExtension = dto.Isin.ToTradeRepublic().IsinWithoutExchangeExtension();
            
        // If the user creates a standing order, it will be executed if the order fulfills it's condition.
        // Therefore, creating an order where the condition is already fulfilled is not allowed.
        var isFulfilled = dto.OrderType.IsOrderFulfilled(trResponse, dto.PriceThreshold);
        if (isFulfilled)
        {
            return new InvalidOrder
            {
                Title = "Invalid trade",
                Message = "Order price is not appropriate for this order type.",
                UserFriendlyMessage = "Order price is not appropriate for this order type. Please try again.",
                AdditionalData = new { Dto = dto, trResponse },
            };
        }
            
        var userQuery = await _unitOfWork.Users
            .FirstAsync(u => u.Uid == uid, u => u.Portfolio);

        if (userQuery.TryTakeError(out error, out var user))
            return error;
        
        var standingOrder = new StandingOrder
        {
            Isin = isinWithoutExchangeExtension,
            Portfolio = user.Portfolio,
            PositionType = dto.PositionType,
            GoodUntil = dto.GoodUntil!.Value,                                                                                                                                                                  
            NumberOfShares = dto.NumberOfShares,
            Price = dto.PriceThreshold,
            OrderType = dto.OrderType, 
        };

        var entity = _unitOfWork.StandingOrders.Add(standingOrder);
            
        _logger.LogInformation("Trying to save standing order with isin {@Isin} for User with uid {@Uid}", dto.Isin, uid);

        var commitResult = await _unitOfWork.Commit();
        if (commitResult.TryTakeError(out error, out _))
            return error;
        
        _logger.LogInformation("Saved standing order with isin {@Isin} for User with uid {@Uid} was successful", dto.Isin, uid);
        _trApiService.AddStandingOrder(dto.Isin, entity.Entity.Id);

        return _mapper.Map<StandingOrderResponseDto>(standingOrder);
    }

    public async Task<Result<StandingOrderResponseDto>> CloseStandingOrder(CloseStandingOrderRequestDto dto, string uid)
    {
        var standingOrderQuery = await _unitOfWork.StandingOrders.FirstAsync(s => s.Id == dto.Id && s.Portfolio.User.Uid == uid);

        if (standingOrderQuery.TryTakeError(out var error, out var standingOrder))
        {
            if (error is not EntityNotFound)
                return error;

            return new EntityNotFound
            {
                Title = "Unable to delete standing order",
                Message = $"The standing order with id: {dto.Id} could not be found or the user is not owner of the standing order.",
                UserFriendlyMessage = "Could not close order. The order may have already been filled.",
                AdditionalData = new { dto, uid }
            };
        }
            
        _unitOfWork.StandingOrders.Remove(standingOrder);
            
        _logger.LogInformation("Trying to delete standing order with id {@StandingOrderId} for User with uid {@Uid}", dto.Id, uid);
        
        var commitResult = await _unitOfWork.Commit();
        if (commitResult.TryTakeError(out error, out _))
            return error;
        
        _logger.LogInformation("Deleting standing order with id {@StandingOrderId} for User with uid {@Uid} was successful", dto.Id, uid);
        
        // TODO: Remove standing order from Trade Republic api service

        return _mapper.Map<StandingOrderResponseDto>(standingOrder);
    }
}