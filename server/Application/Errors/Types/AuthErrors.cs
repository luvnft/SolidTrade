using System.Net;
using Application.Errors.Base;

namespace Application.Errors.Types;

public class NotAuthenticated : BaseError
{
    public override HttpStatusCode Code => HttpStatusCode.Forbidden;
}

public class NotAuthorized : BaseError
{
    public override HttpStatusCode Code => HttpStatusCode.Unauthorized;

    public static NotAuthorized PrivatePortfolio()
    {
        return new NotAuthorized
        {
            Title = "Portfolio is private",
            Message = "Tried to access other user's portfolio",
            UserFriendlyMessage = "This portfolio is private.",
        };
    }
}