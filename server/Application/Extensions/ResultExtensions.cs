using Application.Models.Types;

namespace Application.Extensions;

public static class ResultExtensions
{
    public static async Task<Result<bool>> InvertBoolResult(this Task<Result<bool>> result)
        => InvertBoolResult(await result);
    
    private static Result<bool> InvertBoolResult(Result<bool> result)
    {
        if (result.IsFailure)
            return result;

        return !result.ResultUnsafe;
    }
}