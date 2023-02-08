using System.Net;
using Application.Errors.Base;

namespace Application.Errors.Types;

public class TradeRepublicRequestTimeout : BaseError
{
    public override HttpStatusCode Code => HttpStatusCode.InternalServerError;

    public static TradeRepublicRequestTimeout Default(string requestString, Exception e)
    {
        return new TradeRepublicRequestTimeout
        {
            Title = "Task timeout",
            Message = "Fetching product using trade republic api took too long.",
            AdditionalData = new { RequestString = requestString },
            Exception = e,
        };
    }
}

public class UnexpectedTradeRepublicRequestError : BaseError
{
    public override HttpStatusCode Code => HttpStatusCode.InternalServerError;

}