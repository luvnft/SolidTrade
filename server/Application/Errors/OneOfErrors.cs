using System.Net;
using Application.Errors.Base;

namespace Application.Errors;

/* Service */
public class UserCreateFailed : BaseError
{
    // protected override HttpStatusCode Code => HttpStatusCode.Accepted;
}
public class UserUpdateFailed : BaseError
{
}
public class UserDeleteFailed : BaseError
{
}

public class TradeFailed : BaseError
{
}
public class InsufficientFounds : BaseError
{
}
public class StockMarketClosed : BaseError
{
}
public class InvalidState : BaseError
{
}

public class NotAuthenticated : BaseError
{
}
public class NotAuthorized : BaseError
{
}

// Todo: Delete UnexpectedError class and create classes for each error.
public class UnexpectedError : BaseError
{
}

/* Database */
public class NotFound : BaseError
{
    protected override HttpStatusCode Code => HttpStatusCode.NotFound;
}
public class UnexpectedDatabaseError : BaseError
{
}
