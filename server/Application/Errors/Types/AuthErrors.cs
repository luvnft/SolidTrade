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
}