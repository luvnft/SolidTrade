namespace Application.Common.Interfaces.Services;

public interface IIdentityService
{
    Task<(bool, string)> VerifyUserToken(string token, CancellationToken ct = default);
    Task DeleteUser(string uid, CancellationToken ct = default);
}