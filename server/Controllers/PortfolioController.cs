using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using SolidTradeServer.Common;
using SolidTradeServer.Data.Dtos.Portfolio.Request;
using SolidTradeServer.Services;
using static SolidTradeServer.Common.Shared;

namespace SolidTradeServer.Controllers
{
    [ApiController]
    [Route("/portfolios")]
    public class PortfolioController : Controller
    {
        private readonly PortfolioService _portfolioService;
        private readonly NotificationService _notificationService;

        public PortfolioController(PortfolioService portfolioService, NotificationService notificationService)
        {
            _portfolioService = portfolioService;
            _notificationService = notificationService;
        }

        [HttpGet]
        public async Task<IActionResult> Get([FromQuery] GetPortfolioRequestDto dto)
        {
            // Temporary send notification test
            await _notificationService.SendNotification(-1, Request.Headers["DeviceToken"], "Test", "Message");
            
            return MatchResult(await _portfolioService.GetPortfolio(dto, Request.Headers[Shared.UidHeader]));
        }
    }
}