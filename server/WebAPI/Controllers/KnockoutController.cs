using Application.Common.Interfaces.Services;
using Application.Models.Dtos.Shared.Common;
using Domain.Enums;
using Microsoft.AspNetCore.Mvc;
using static Application.Common.ApplicationConstants;
using static WebAPI.Common.MatchOneOfResult;

namespace WebAPI.Controllers;

[ApiController]
[Route("/knockouts")]
public class KnockoutController : Controller
{
    private readonly IPositionService _positionService;

    public KnockoutController(IPositionService positionService)
    {
        _positionService = positionService;
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Get(int id)
        => MatchResult(
            await _positionService.GetPositionAsync(id, Request.Headers[UidHeader]));

    [HttpPost]
    public async Task<IActionResult> BuyKnockout([FromBody] BuyOrSellRequestDto dto)
        => MatchResult(
            await _positionService.BuyPositionAsync(dto, Request.Headers[UidHeader], PositionType.Knockout));

    [HttpDelete]
    public async Task<IActionResult> SellKnockout([FromBody] BuyOrSellRequestDto dto)
        => MatchResult(
            await _positionService.SellPositionAsync(dto, Request.Headers[UidHeader], PositionType.Knockout));
}