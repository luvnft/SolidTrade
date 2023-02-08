using System.Net;

namespace Application.Errors.Base;

public abstract class BaseError
{
    public string Title { get; init; }
    public string Message { get; init; }
    public string UserFriendlyMessage { get; init; }
    public object AdditionalData { get; init; }
    public Exception Exception { get; set; }
    public abstract HttpStatusCode Code { get; }
}