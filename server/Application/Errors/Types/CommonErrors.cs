using System.Net;
using Application.Errors.Base;

namespace Application.Errors.Types;

public class InvalidRequestDto : BaseError
{
    public override HttpStatusCode Code => HttpStatusCode.BadRequest;
}

public class UnexpectedError : BaseError
{
    public override HttpStatusCode Code => HttpStatusCode.InternalServerError;
}
