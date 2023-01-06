using System.Net;
using Application.Common.Interfaces.Services.TradeRepublic;
using Application.Errors.Types;
using Application.Models.Dtos.TradeRepublic;
using Application.Services.TradeRepublic;
using Domain.Common.Position;
using Domain.Enums;
using OneOf;

namespace Application.Common;

public static class Shared
{
    public static string GetTradeRepublicProductInfoRequestString(string isin)
        => "{\"type\":\"instrument\",\"id\":\"" + isin + "\"}";

    public static string GetTradeRepublicProductPriceRequestString(string isin)
        => "{\"type\":\"ticker\",\"id\":\"" + isin + "\"}";

    public static string GetTradeRepublicProductImageUrl(string isin, ProductImageThemeColor themeColor)
        => $"https://assets.traderepublic.com/img/logos/{isin}/{themeColor.ToString().ToLower()}.svg";

    public static string GetTradingViewIndexProductImageUrl(string isin)
        => $"https://s3-symbol-logo.tradingview.com/country/{isin[..2]}.svg";

    public static string ToIsinWithoutExchangeExtension(string isin)
    {
        var i = isin.IndexOf('.');
        return i == -1 ? isin.Trim().ToUpper() : isin[..i].Trim().ToUpper();
    }
        
    public static IPosition CalculateNewPosition(IPosition p1, IPosition p2)
    {
        PositionOld positionOld = new PositionOld
        {
            NumberOfShares = p1.NumberOfShares + p2.NumberOfShares,
        };

        positionOld.BuyInPrice =
            (p1.BuyInPrice * p1.NumberOfShares +
             p2.BuyInPrice * p2.NumberOfShares) / positionOld.NumberOfShares;

        return positionOld;
    }
                
    public static bool GetOngoingProductHandler(OrderType type, TradeRepublicProductPriceResponseDto value, decimal price)
    {
        return type switch
        {
            // Current has to be below
            OrderType.BuyLimitOrder => price >= value.Ask.Price,
            // Current has to be above
            OrderType.BuyStopOrder => value.Ask.Price >= price,
            // Current has to be above (take profit)
            OrderType.SellLimitOrder => price <= value.Bid.Price,
            // Current has to be below (stop loss)
            OrderType.SellStopOrder => value.Bid.Price <= price,
        };
    }
        
    public static async Task<Result<T>> MakeTrRequestWithService<T>(ITradeRepublicApi trService, string requestString)
    {
        var cts = new CancellationTokenSource();
        T trResponse;
            
        try
        {
            cts.CancelAfter(1000 * 10);
            var oneOfResult =
                await trService.AddRequest<T>(requestString, cts.Token);

            if (oneOfResult.TryPickT1(out var error, out trResponse))
                return error;
        }
        catch (OperationCanceledException e)
        {
            return TradeRepublicRequestTimeout.Default(requestString, e);
        }
        finally { cts.Dispose(); }

        return trResponse;
    }
}