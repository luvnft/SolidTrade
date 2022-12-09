using Application.Common;
using Application.Errors.Base;
using Application.Errors.Common;
using Application.Models.Types;
using Microsoft.AspNetCore.Mvc;
using Serilog;
using ILogger = Serilog.ILogger;

namespace WebAPI.Common;

public static class MatchOneOfResult
{
    private static readonly ILogger Logger = Log.ForContext(typeof(MatchOneOfResult));
    
    public static IActionResult MatchResult<T>(Result<T> value)
    {
        return value.Match(response => new ObjectResult(response), MatchError);
    }
    
    public static IActionResult MatchResult<T>(OneOf.OneOf<T, ErrorResponse> value)
    {
        return value.Match(
            response => new ObjectResult(response),
            err =>
            {
                var ex = err.Error.Exception;
                err.Error.Exception = ex is not null ? new Exception("Exception is defined in the 'exceptions' field.") : null;

                return new ObjectResult(new UnexpectedError
                {
                    Title = err.Error.Title,
                    UserFriendlyMessage = err.Error.UserFriendlyMessage,
                    Message = err.Error.Message,
                }) {StatusCode = (int) err.Code};
            });
    }

    public static ObjectResult MatchError(BaseError err)
    {
        var ex = err.Exception;
        err.Exception = ex is not null ? new Exception("Exception is defined in the 'exceptions' field.") : null;
        Logger.Error(ex, ApplicationConstants.LogMessageTemplate, err);

        return new ObjectResult(new UnexpectedError
        {
            Title = err.Title,
            UserFriendlyMessage = err.UserFriendlyMessage,
            Message = err.Message,
        }) { StatusCode = (int)err.Code };
    }
}