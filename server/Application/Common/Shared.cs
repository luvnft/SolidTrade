using System.Net;
using Application.Common.Interfaces.Services.TradeRepublic;
using Application.Errors;
using Application.Errors.Common;
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
        Position position = new Position
        {
            NumberOfShares = p1.NumberOfShares + p2.NumberOfShares,
        };

        position.BuyInPrice =
            (p1.BuyInPrice * p1.NumberOfShares +
             p2.BuyInPrice * p2.NumberOfShares) / position.NumberOfShares;

        return position;
    }
                
    public static string GetOrderName(EnterOrExitPositionType type)
    {
        return type switch
        {
            EnterOrExitPositionType.BuyLimitOrder => "buy limit",
            EnterOrExitPositionType.BuyStopOrder => "buy stop",
            EnterOrExitPositionType.SellLimitOrder => "take profit",
            EnterOrExitPositionType.SellStopOrder => "stop loss",
        };
    }

    public static BuyOrSell IsBuyOrSell(EnterOrExitPositionType type)
    {
        return type switch
        {
            EnterOrExitPositionType.BuyLimitOrder => BuyOrSell.Buy,
            EnterOrExitPositionType.BuyStopOrder => BuyOrSell.Buy,
            EnterOrExitPositionType.SellLimitOrder => BuyOrSell.Sell,
            EnterOrExitPositionType.SellStopOrder => BuyOrSell.Sell,
        };
    }
        
    public static bool GetOngoingProductHandler(EnterOrExitPositionType type, TradeRepublicProductPriceResponseDto value, decimal price)
    {
        return type switch
        {
            // Current has to be below
            EnterOrExitPositionType.BuyLimitOrder => price >= value.Ask.Price,
            // Current has to be above
            EnterOrExitPositionType.BuyStopOrder => value.Ask.Price >= price,
            // Current has to be above (take profit)
            EnterOrExitPositionType.SellLimitOrder => price <= value.Bid.Price,
            // Current has to be below (stop loss)
            EnterOrExitPositionType.SellStopOrder => value.Bid.Price <= price,
        };
    }
        
    public static async Task<OneOf<T, ErrorResponse>> MakeTrRequestWithService<T>(ITradeRepublicApi trService, string requestString)
    {
        var cts = new CancellationTokenSource();
        T trResponse;
            
        try
        {
            cts.CancelAfter(1000 * 10);
            var oneOfResult =
                await trService.AddRequest<T>(requestString, cts.Token);

            if (oneOfResult.TryPickT1(out var error, out trResponse))
                return new ErrorResponse(error, HttpStatusCode.InternalServerError);
        }
        catch (OperationCanceledException e)
        {
            return new ErrorResponse(new UnexpectedError
            {
                Title = "Task timeout",
                Message = "Fetching product using trade republic api took too long.",
                AdditionalData = new { requestString },
                Exception = e,
            }, HttpStatusCode.InternalServerError);
        }
        finally { cts.Dispose(); }

        return trResponse;
    }
}