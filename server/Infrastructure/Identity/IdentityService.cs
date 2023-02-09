using Application.Common.Interfaces.Services;
using Microsoft.Extensions.Logging;
using Supabase;
using Success = OneOf.Types.Success;

namespace Infrastructure.Identity;

internal class IdentityService : IIdentityService
{
    private readonly ILogger<IdentityService> _logger;
    private readonly Client _client;
    
    public IdentityService(Client client, ILogger<IdentityService> logger)
    {
        _client = client;
        _logger = logger;
    }

    public async Task<(bool, string)> VerifyUserToken(string token, CancellationToken ct = default)
    {
        try
        {
            var user = await _client.Auth.GetUser(token);
            return (true, user!.Id);
        }
        catch (Exception e)
        {
            _logger.LogError("Failed to verify user token: {0}", e.Message);
            return (false, null);
        } 
    }

    public async Task<Result<Success>> DeleteUser(string uid, string token, CancellationToken ct = default)
    {
        try
        {
            await _client.Auth.DeleteUser(uid, token);
            return new Success();
        }
        catch (Exception e)
        {
            return IdentityUserDeleteFailed.Default(uid, e);
        }
    }
}