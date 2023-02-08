using Application.Models.Dtos.TradeRepublic;
using Domain.Enums;

namespace Application.Extensions;

public static class OrderTypeExtensions
{
    public static bool IsOrderFulfilled(this OrderType type, TradeRepublicProductPriceResponseDto value, decimal orderPrice)
    {
        return type switch
        {
            // Current has to be below
            OrderType.BuyLimitOrder => orderPrice >= value.Ask.Price,
            // Current has to be above
            OrderType.BuyStopOrder => value.Ask.Price >= orderPrice,
            // Current has to be above (take profit)
            OrderType.SellLimitOrder => orderPrice <= value.Bid.Price,
            // Current has to be below (stop loss)
            OrderType.SellStopOrder => value.Bid.Price <= orderPrice,
        };
    }
    
    public static BuyOrSell IsBuyOrSell(this OrderType type)
    {
        return type switch
        {
            OrderType.BuyLimitOrder => BuyOrSell.Buy,
            OrderType.BuyStopOrder => BuyOrSell.Buy,
            OrderType.SellLimitOrder => BuyOrSell.Sell,
            OrderType.SellStopOrder => BuyOrSell.Sell,
        };
    }
    
    public static string UserFriendlyFullName(this OrderType type)
    {
        return type switch
        {
            OrderType.BuyLimitOrder => "buy limit",
            OrderType.BuyStopOrder => "buy stop",
            OrderType.SellLimitOrder => "take profit",
            OrderType.SellStopOrder => "stop loss",
        };
    }
}