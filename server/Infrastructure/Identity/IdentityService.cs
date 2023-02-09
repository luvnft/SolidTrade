using Application.Common.Interfaces.Services;
using Application.Errors.Types;
using Application.Models.Types;
using FirebaseAdmin.Auth;
using Supabase;
using Success = OneOf.Types.Success;

namespace Infrastructure.Identity;

internal class IdentityService : IIdentityService
{
    private readonly Client _client;
    
    public IdentityService(Client client)
    {
        _client = client;
    }

    public async Task<(bool, string)> VerifyUserToken(string token, CancellationToken ct = default)
    {
        try
        {
            var x = await _client.Auth.GetUser(token);
            var x = await _client.Auth.
            return (true, "");
        }
        catch (Exception e)
        {
            Console.WriteLine(e);
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