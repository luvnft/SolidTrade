using Application.Common;
using Application.Errors;
using Application.Errors.Common;
using Microsoft.AspNetCore.Mvc;
using OneOf;
using Serilog;
using ILogger = Serilog.ILogger;

namespace WebAPI.Common;

public static class MatchOneOfResult
{
    private static readonly ILogger Logger = Log.ForContext(typeof(MatchOneOfResult));
    
    public static IActionResult MatchResult<T>(OneOf<T, ErrorResponse> value)
    {
        return value.Match(response => new ObjectResult(response), MatchError);
    }

    public static ObjectResult MatchError(ErrorResponse err)
    {
        var ex = err.Error.Exception;
        err.Error.Exception = ex is not null ? new Exception("Exception is defined in the 'exceptions' field.") : null;
        Logger.Error(ex, ApplicationConstants.LogMessageTemplate, err.Error);

        return new ObjectResult(new UnexpectedError
        {
            Title = err.Error.Title,
            UserFriendlyMessage = err.Error.UserFriendlyMessage,
            Message = err.Error.Message,
        }) { StatusCode = (int)err.Code };
    }
}