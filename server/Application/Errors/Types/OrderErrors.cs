using System.Net;
using Application.Errors.Base;

namespace Application.Errors.Types;

public class InvalidOrder : BaseError
{
    public override HttpStatusCode Code => HttpStatusCode.BadRequest;
}

public class InsufficientFunds : BaseError
{
    public override HttpStatusCode Code => HttpStatusCode.PaymentRequired;
}

public class StockMarketClosed : BaseError
{
    public override HttpStatusCode Code => HttpStatusCode.BadRequest;

    public static StockMarketClosed Default()
    {
        return new StockMarketClosed
        {
            Title = "Stock market closed",
            Message = "Tried to trade while stock market was closed.",
            UserFriendlyMessage = "The stock market is unfortunately already closed.",
        };
    }
}