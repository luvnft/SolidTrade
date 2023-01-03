using Application.Common.Interfaces.Services;
using Application.Models.Dtos.Shared.Common;
using Domain.Enums;
using Microsoft.AspNetCore.Mvc;
using static Application.Common.ApplicationConstants;
using static WebAPI.Common.MatchOneOfResult;


namespace WebAPI.Controllers;

[ApiController]
[Route("/warrants")]
public class WarrantController : Controller
{
    private readonly IPositionService _positionService;

    public WarrantController(IPositionService positionService)
    {
        _positionService = positionService;
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Get(int id)
        => MatchResult(
            await _positionService.GetPositionAsync(id, Request.Headers[UidHeader]));

    [HttpPost]
    public async Task<IActionResult> BuyWarrant([FromBody] BuyOrSellRequestDto dto)
        => MatchResult(
            await _positionService.BuyPositionAsync(dto, Request.Headers[UidHeader], PositionType.Warrant));

    [HttpDelete]
    public async Task<IActionResult> SellWarrant([FromBody] BuyOrSellRequestDto dto)
        => MatchResult(
            await _positionService.SellPositionAsync(dto, Request.Headers[UidHeader], PositionType.Warrant));
}