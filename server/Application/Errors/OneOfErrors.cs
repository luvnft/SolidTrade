using System.Net;
using Application.Errors.Base;

namespace Application.Errors.Common;

/* Service */
// TODO: All errors should have their own dedicated file. Like the UserErrors.cs
public class UserCreateFailed : BaseError
{
    public override HttpStatusCode Code => HttpStatusCode.Accepted;
}
public class UserUpdateFailed : BaseError
{
    public override HttpStatusCode Code => HttpStatusCode.Accepted;
}
public class UserDeleteFailed : BaseError
{
    public override HttpStatusCode Code => HttpStatusCode.Accepted;
}

public class TradeFailed : BaseError
{
    public override HttpStatusCode Code => HttpStatusCode.Accepted;
}
public class InsufficientFounds : BaseError
{
    public override HttpStatusCode Code => HttpStatusCode.Accepted;
}
public class StockMarketClosed : BaseError
{
    public override HttpStatusCode Code => HttpStatusCode.Accepted;
}
public class InvalidState : BaseError
{
    public override HttpStatusCode Code => HttpStatusCode.Accepted;
}

public class NotAuthenticated : BaseError
{
    public override HttpStatusCode Code => HttpStatusCode.Accepted;
}
public class NotAuthorized : BaseError
{
    public override HttpStatusCode Code => HttpStatusCode.Accepted;
}

// Todo: Delete UnexpectedError class and create classes for each error.
public class UnexpectedError : BaseError
{
    public override HttpStatusCode Code => HttpStatusCode.Accepted;
}

/* Database */
public class NotFound : BaseError
{
    public override HttpStatusCode Code => HttpStatusCode.NotFound;
}
public class UnexpectedDatabaseError : BaseError
{
    public override HttpStatusCode Code => HttpStatusCode.Accepted;
}
