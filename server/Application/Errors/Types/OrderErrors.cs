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
    public static InsufficientFunds Default(decimal totalPrice, decimal userBalance)
    {
        return new InsufficientFunds
        {
            Title = "Insufficient funds",
            Message = "User founds not sufficient for purchase.",
            UserFriendlyMessage =
                $"Balance insufficient. The total price is {totalPrice} but you have a balance of {userBalance}.",
        };
    }
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