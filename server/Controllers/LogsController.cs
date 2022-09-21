using System.Text.Json;
using Microsoft.AspNetCore.Mvc;
using Serilog;
using SolidTradeServer.Common;
using SolidTradeServer.Data.Models.Errors;

namespace SolidTradeServer.Controllers
{
    [ApiController]
    [Route("/logs")]
    public class LogsController : Controller
    {
        private readonly ILogger _logger = Log.ForContext<LogsController>();
        
        [HttpPost]
        public IActionResult SendLogs([FromBody] ClientLog log)
        {
            var err = new UnexpectedError
            {
                Title = log.Title,
                Message = log.Message,
                AdditionalData = new { log.SenderId  }
            };
            
            _logger.Fatal(JsonSerializer.Serialize(err));
            return Ok();
        }
    }

    public class ClientLog
    {
        public string SenderId { get; set; }
        public string Title { get; set; }
        public string? Message { get; set; }
    }
}