using Application.Errors.Base;
using OneOf;

namespace Application.Models.Types;

[GenerateOneOf]
public partial class Result<T> : OneOfBase<T, BaseError>
{
    public bool IsSuccessful => IsT0;
    public bool IsFailure => IsT1;
    
    public bool TryPickResult(out T result, out BaseError error)
        => TryPickT0(out result, out error);
    
    public bool TryPickError(out BaseError error, out T result)
        => TryPickT1(out error, out result);
}
