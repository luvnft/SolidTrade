using System.Net;
using Application.Errors.Base;

namespace Application.Errors.Types;

public class InvalidFormat : BaseError
{
    public override HttpStatusCode Code => HttpStatusCode.InternalServerError;
}