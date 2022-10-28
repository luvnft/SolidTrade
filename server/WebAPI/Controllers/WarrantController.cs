using Application.Common.Interfaces.Services;
using Application.Models.Dtos.Shared.Common;
using Microsoft.AspNetCore.Mvc;
using static Application.Common.ApplicationConstants;
using static WebAPI.Common.MatchOneOfResult;


namespace WebAPI.Controllers;

[ApiController]
[Route("/warrants")]
public class WarrantController : Controller
{
    private readonly IWarrantService _warrantService;

    public WarrantController(IWarrantService warrantService)
    {
        _warrantService = warrantService;
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Get(int id)
        => MatchResult(
            await _warrantService.GetWarrant(id, Request.Headers[UidHeader]));

    [HttpPost]
    public async Task<IActionResult> BuyWarrant([FromBody] BuyOrSellRequestDto dto)
        => MatchResult(
            await _warrantService.BuyWarrant(dto, Request.Headers[UidHeader]));

    [HttpDelete]
    public async Task<IActionResult> SellWarrant([FromBody] BuyOrSellRequestDto dto)
        => MatchResult(
            await _warrantService.SellWarrant(dto, Request.Headers[UidHeader]));
}