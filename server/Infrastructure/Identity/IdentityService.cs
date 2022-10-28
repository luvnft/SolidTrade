using Application.Common.Interfaces.Services;
using FirebaseAdmin.Auth;
using Microsoft.Extensions.Configuration;

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

    public Task DeleteUser(string uid, CancellationToken ct = default) 
        => FirebaseAuth.DefaultInstance.DeleteUserAsync(uid, ct);
}