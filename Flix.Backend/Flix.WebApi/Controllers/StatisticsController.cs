using Flix.Model.Responses;
using Flix.Services.Interfaces;
using Flix.WebApi.Filters;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Flix.WebApi.Controllers
{
    [ApiController]
    [Authorize]
    [Route("[controller]")]
    public class StatisticsController : ControllerBase
    {
        protected readonly IStatisticsService _statisticsService;
        public StatisticsController(IStatisticsService statisticsService)
        {
            _statisticsService = statisticsService;
        }

        [HttpGet]
        [Authorization("Admin")]
        public async Task<ActionResult<AdminStatisticsResponse>> Get()
        {
            return Ok(await _statisticsService.GetStatistics());
        }
    }
}