using Application.Models.Dtos.Authentication.Response;

namespace Application.Common.Interfaces.Services;

public interface IAuthenticationService
{
    Task<Result<CreateMagicLinkResponseDto>> CreateMagicLink(string host, string userEmail);
    Result<string> VerifyMagicLinkCode(Guid code);
    Result<CheckMagicLinkStatusResponseDto> CheckMagicLinkStatus(Guid code);
    (bool, string) VerifyUserToken(string token);
}