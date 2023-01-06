using Application.Models.Dtos.TradeRepublic;
using Domain.Entities;
using Domain.Enums;

namespace Application.Common.Interfaces.Services;

public interface IStandingOrderHandlerService
{
    public Task<Result<StandingOrderState>> HandleStandingOrderTradeMessage(TradeRepublicProductPriceResponseDto dto, int standingOrderId);
}