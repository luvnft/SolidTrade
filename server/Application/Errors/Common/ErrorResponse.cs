using System.Net;
using Application.Errors.Base;

namespace Application.Errors.Common;

public class ErrorResponse
{
    public ErrorResponse(BaseError error, HttpStatusCode code)
    {
        Error = error;
        Code = code;
    }

    public HttpStatusCode Code { get; }
    public BaseError Error { get; }
}