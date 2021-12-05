using Microsoft.AspNetCore.Mvc;

namespace SolidTradeServer.Controllers
{
    [ApiController]
    [Route("/")]
    public class IndexController : Controller
    {
        [HttpGet]
        public IActionResult GetCheck()
        {
            return Ok("Test");
        }
        
        [HttpGet("HealthCheck")]
        public IActionResult GetHealthCheck()
        {
            return GetCheck();
        }
    }
}