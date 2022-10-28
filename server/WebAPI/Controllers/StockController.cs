using Application.Common.Interfaces.Services;
using Application.Models.Dtos.Shared.Common;
using Microsoft.AspNetCore.Mvc;
using static Application.Common.ApplicationConstants;
using static WebAPI.Common.MatchOneOfResult;

namespace WebAPI.Controllers;

[ApiController]
[Route("/stocks")]
public class StockController : Controller
{
    private readonly IStockService _stockService;

    public StockController(IStockService stockService)
    {
        _stockService = stockService;
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Get(int id)
        => MatchResult(
            await _stockService.GetStock(id, Request.Headers[UidHeader]));

    [HttpPost]
    public async Task<IActionResult> BuyStock([FromBody] BuyOrSellRequestDto dto)
        => MatchResult(
            await _stockService.BuyStock(dto, Request.Headers[UidHeader]));

    [HttpDelete]
    public async Task<IActionResult> SellStock([FromBody] BuyOrSellRequestDto dto)
        => MatchResult(
            await _stockService.SellStock(dto, Request.Headers[UidHeader]));
}