using Application.Common.Interfaces.Services.TradeRepublic;
using Application.Models.Dtos.TradeRepublic;
using Domain.Entities;
using Domain.Enums;

namespace Application.Common.Interfaces.Services;

public interface IOngoingProductsService
{
    public (List<OngoingWarrantPosition>, List<OngoingKnockoutPosition>) GetAllOngoingPositions();

    public OngoingTradeResponse HandleOngoingWarrantTradeMessage(ITradeRepublicApi trService,
        TradeRepublicProductPriceResponseDto trMessage, PositionType type, int ongoingProductId);

    public OngoingTradeResponse HandleOngoingKnockoutTradeMessage(ITradeRepublicApi trService,
        TradeRepublicProductPriceResponseDto trMessage, PositionType type, int ongoingProductId);
}