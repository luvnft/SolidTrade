using Application.Common.Interfaces.Services;
using Application.Models.Dtos.Authentication.Request;
using Microsoft.AspNetCore.Mvc;
using static WebAPI.Common.MatchOneOfResult;

namespace WebAPI.Controllers;

[ApiController]
[Route("/auth")]
public class AuthenticationController : Controller
{
    private readonly IAuthenticationService _authenticationService;

    public AuthenticationController(IAuthenticationService authenticationService)
    {
        _authenticationService = authenticationService;
    }
    

    [HttpGet("status")]
    public IActionResult CheckMagicLinkStatus([FromQuery] CheckMagicLinkStatusRequestDto dto)
        => MatchResult(_authenticationService.CheckMagicLinkStatus(dto.ConfirmationStatusCode));

    [HttpGet]
    public IActionResult VerifyMagicLink([FromQuery] VerifyMagicLinkCodeRequestDto dto)
    {
        var result = _authenticationService.VerifyMagicLinkCode(dto.ConfirmationCode);
        return result.IsFailure ? MatchResult(result) : Content(result.ResultUnsafe, "text/html");
    }

    [HttpPost]
    public async Task<IActionResult> CreateMagicLink(CreateMagicLinkRequestDto dto)
        => MatchResult(await _authenticationService.CreateMagicLink(GetHost(), dto.Email));
    
    private string GetHost()
    {
        var host = HttpContext.Request.Host.Host;
        var port = HttpContext.Request.Host.Port;
        var fullHost = port is null ? host : $"{host}:{port}";
        
        var isLocalHost = host == "localhost";
        return isLocalHost ? $"http://{fullHost}" : $"https://{fullHost}";
    }
}