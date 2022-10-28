namespace Application.Errors.Base;

public abstract class BaseError
{
    // Todo: Title is potentially obsolete since the class name should be a good enough description.
    public string Title { get; init; }
    public string Message { get; init; }
    public string UserFriendlyMessage { get; init; }
    public object AdditionalData { get; init; }
    public Exception Exception { get; set; }
}