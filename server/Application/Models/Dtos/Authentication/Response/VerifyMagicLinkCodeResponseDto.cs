namespace Application.Models.Dtos.Authentication.Response;

public class VerifyMagicLinkCodeResponseDto
{
    public string Token { get; set; }
    
    public string RefreshToken { get; set; }
}