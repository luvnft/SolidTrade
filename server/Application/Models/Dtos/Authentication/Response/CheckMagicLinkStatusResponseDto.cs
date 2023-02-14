using Domain.Enums;

namespace Application.Models.Dtos.Authentication.Response;

public class CheckMagicLinkStatusResponseDto
{
    public MagicLinkStatus Status { get; set; }
    public VerifyMagicLinkCodeResponseDto Token { get; set; }
}