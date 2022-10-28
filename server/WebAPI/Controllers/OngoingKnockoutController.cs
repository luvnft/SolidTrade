using Application.Common.Interfaces.Services;
using Application.Models.Dtos.Shared.OngoingPosition.Request;
using Microsoft.AspNetCore.Mvc;
using static Application.Common.ApplicationConstants;
using static WebAPI.Common.MatchOneOfResult;

namespace WebAPI.Controllers;

[ApiController]
[Route("/knockouts/ongoing")]
public class OngoingKnockoutController : Controller
{
    private readonly IOngoingKnockoutService _ongoingKnockoutService;

    public OngoingKnockoutController(IOngoingKnockoutService ongoingKnockoutService)
    {
        _ongoingKnockoutService = ongoingKnockoutService;
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Get(int id)
        => MatchResult(
            await _ongoingKnockoutService.GetOngoingKnockout(id, Request.Headers[UidHeader]));

    [HttpPost]
    public async Task<IActionResult> OpenOngoingWarrant([FromBody] OngoingPositionRequestDto dto)
        => MatchResult(
            await _ongoingKnockoutService.OpenOngoingKnockout(dto, Request.Headers[UidHeader]));

    [HttpDelete]
    public async Task<IActionResult> CloseOngoingWarrant([FromBody] CloseOngoingPositionRequestDto dto)
        => MatchResult(
            await _ongoingKnockoutService.CloseOngoingKnockout(dto, Request.Headers[UidHeader]));
}