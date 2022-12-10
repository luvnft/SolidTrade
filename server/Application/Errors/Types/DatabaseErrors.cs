using System.Net;
using Application.Errors.Base;

namespace Application.Errors.Types;

public class EntityNotFound : BaseError
{
    public override HttpStatusCode Code => HttpStatusCode.NotFound;
}

public class UnexpectedDatabaseError : BaseError
{
    public override HttpStatusCode Code => HttpStatusCode.InternalServerError;
}
