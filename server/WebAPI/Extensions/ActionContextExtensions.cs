using Microsoft.AspNetCore.Mvc;

namespace WebAPI.Extensions;

public static class ActionContextExtensions
{
    public static string GetUserFriendlyValidationError(this ActionContext actionContext)
    {
        (string fieldName, var value) = actionContext.ModelState.First(e => e.Value.Errors.Any());
        string errorMessage = value.Errors.First().ErrorMessage;

        return $"{fieldName} validation error. {errorMessage}";
    }
}