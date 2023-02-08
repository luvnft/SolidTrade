using Application.Common.Interfaces.Services;
using Application.Models.Dtos.Shared.OngoingPosition.Request;
using Application.Models.Dtos.StandingOrder.Request;
using Microsoft.AspNetCore.Mvc;
using static Application.Common.ApplicationConstants;
using static WebAPI.Common.MatchOneOfResult;

namespace WebAPI.Controllers;

[ApiController]
[Route("/standing-orders")]
public class StandingOrderController : Controller
{
    private readonly IStandingOrderService _standingOrderService;

    public StandingOrderController(IStandingOrderService standingOrderService)
    {
        _standingOrderService = standingOrderService;
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Get(int id)
        => MatchResult(
            await _standingOrderService.GetStandingOrder(id, Request.Headers[UidHeader]));

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateStandingOrderRequestDto dto)
        => MatchResult(
            await _standingOrderService.CreateStandingOrder(dto, Request.Headers[UidHeader]));

    [HttpDelete]
    public async Task<IActionResult> Close([FromBody] CloseStandingOrderRequestDto dto)
        => MatchResult(
            await _standingOrderService.CloseStandingOrder(dto, Request.Headers[UidHeader]));
}