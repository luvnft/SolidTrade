using Application.Models.Types;
using Success = OneOf.Types.Success;

namespace Application.Common.Interfaces.Services;

public interface IIdentityService
{
    Task<(bool, string)> VerifyUserToken(string token, CancellationToken ct = default);
    Task<Result<Success>> DeleteUser(string uid, CancellationToken ct = default);
}