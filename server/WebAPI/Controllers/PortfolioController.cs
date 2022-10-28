using Application.Common.Interfaces.Services;
using Application.Models.Dtos.Portfolio.Request;
using Microsoft.AspNetCore.Mvc;
using static Application.Common.ApplicationConstants;
using static WebAPI.Common.MatchOneOfResult;

namespace WebAPI.Controllers;

[ApiController]
[Route("/portfolios")]
public class PortfolioController : Controller
{
    private readonly IPortfolioService _portfolioService;

    public PortfolioController(IPortfolioService portfolioService)
    {
        _portfolioService = portfolioService;
    }

    [HttpGet]
    public async Task<IActionResult> Get([FromQuery] GetPortfolioRequestDto dto)
        => MatchResult(await _portfolioService.GetPortfolio(dto, Request.Headers[UidHeader]));
}