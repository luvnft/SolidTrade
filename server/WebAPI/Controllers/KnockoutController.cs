using Application.Common.Interfaces.Services;
using Application.Models.Dtos.Shared.Common;
using Microsoft.AspNetCore.Mvc;
using static Application.Common.ApplicationConstants;
using static WebAPI.Common.MatchOneOfResult;

namespace WebAPI.Controllers;

[ApiController]
[Route("/knockouts")]
public class KnockoutController : Controller
{
    private readonly IKnockoutService _knockoutService;

    public KnockoutController(IKnockoutService knockoutService)
    {
        _knockoutService = knockoutService;
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Get(int id)
        => MatchResult(
            await _knockoutService.GetKnockout(id, Request.Headers[UidHeader]));

    [HttpPost]
    public async Task<IActionResult> BuyKnockout([FromBody] BuyOrSellRequestDto dto)
        => MatchResult(
            await _knockoutService.BuyKnockout(dto, Request.Headers[UidHeader]));

    [HttpDelete]
    public async Task<IActionResult> SellKnockout([FromBody] BuyOrSellRequestDto dto)
        => MatchResult(
            await _knockoutService.SellKnockout(dto, Request.Headers[UidHeader]));
}