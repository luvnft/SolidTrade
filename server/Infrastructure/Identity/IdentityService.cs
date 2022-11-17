using Application.Common.Interfaces.Services;
using Application.Errors.Common.User;
using Application.Models.Types;
using FirebaseAdmin.Auth;
using Microsoft.Extensions.Configuration;
using Success = OneOf.Types.Success;

namespace Infrastructure.Identity;

internal class IdentityService : IIdentityService
{
    private readonly IConfiguration _configuration;
    
    public IdentityService(IConfiguration configuration)
    {
        _configuration = configuration;
    }

    public async Task<(bool, string)> VerifyUserToken(string token, CancellationToken ct = default)
    {
        // When we are testing the api we just provide the uid in the Authorization header to authenticate.
        if (_configuration.GetValue<bool>("IsLocalDevelopment"))
        {
            try
            {
                await FirebaseAuth.DefaultInstance.GetUserAsync(token, ct);
                return (true, token);
            }
            catch { }
        }
            
        try
        {
            var decodedToken = await FirebaseAuth.DefaultInstance
                .VerifyIdTokenAsync(token, ct);
            return (true, decodedToken.Uid);
        }
        catch
        {
            return (false, null);
        } 
    }

    public async Task<Result<Success>> DeleteUser(string uid, CancellationToken ct = default)
    {
        try
        {
            await FirebaseAuth.DefaultInstance.DeleteUserAsync(uid, ct);
            return new Success();
        }
        catch (Exception e)
        {
            return IdentityUserDeleteFailed.Default(uid, e);
        }
    }
}