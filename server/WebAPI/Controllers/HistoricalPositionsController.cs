using Application.Common.Interfaces.Services;
using Microsoft.AspNetCore.Mvc;
using static Application.Common.ApplicationConstants;
using static WebAPI.Common.MatchOneOfResult;

namespace WebAPI.Controllers;

[ApiController]
[Route("/historicalpositions")]
public class HistoricalPositionsController : Controller
{
    private readonly IHistoricalPositionsService _historicalPositionsService;

    public HistoricalPositionsController(IHistoricalPositionsService historicalPositionsService)
    {
        _historicalPositionsService = historicalPositionsService;
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Get(int id)
        => MatchResult(
            await _historicalPositionsService.GetHistoricalPositions(id, Request.Headers[UidHeader]));
}