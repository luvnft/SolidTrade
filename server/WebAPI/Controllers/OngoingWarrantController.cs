using Application.Common.Interfaces.Services;
using Application.Models.Dtos.Shared.OngoingPosition.Request;
using Microsoft.AspNetCore.Mvc;
using static Application.Common.ApplicationConstants;
using static WebAPI.Common.MatchOneOfResult;

namespace WebAPI.Controllers;

[ApiController]
[Route("/warrants/ongoing")]
public class OngoingWarrantController : Controller
{
    private readonly IOngoingWarrantService _ongoingWarrantService;

    public OngoingWarrantController(IOngoingWarrantService ongoingWarrantService)
    {
        _ongoingWarrantService = ongoingWarrantService;
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Get(int id)
        => MatchResult(
            await _ongoingWarrantService.GetOngoingWarrant(id, Request.Headers[UidHeader]));

    [HttpPost]
    public async Task<IActionResult> OpenOngoingWarrant([FromBody] OngoingPositionRequestDto dto)
        => MatchResult(
            await _ongoingWarrantService.OpenOngoingWarrant(dto, Request.Headers[UidHeader]));

    [HttpDelete]
    public async Task<IActionResult> CloseOngoingWarrant([FromBody] CloseOngoingPositionRequestDto dto)
        => MatchResult(
            await _ongoingWarrantService.CloseOngoingWarrant(dto, Request.Headers[UidHeader]));
}