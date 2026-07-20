using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Flix.WebApi.Controllers
{
    [ApiController]
    [Authorize]
    [Route("[controller]")]
    public abstract class BaseReadController<TResponse, TSearch, TService> : ControllerBase
        where TSearch : BaseSearchObject
        where TService : IBaseReadService<TResponse, TSearch>
    {
        protected readonly TService _service;

        protected BaseReadController(TService service)
        {
            _service = service;
        }

        [HttpGet]
        public virtual async Task<ActionResult<PageResult<TResponse>>> Get([FromQuery] TSearch? search)
        {
            return Ok(await _service.GetAsync(search));
        }

        [HttpGet("{id}")]
        public virtual async Task<ActionResult<TResponse>> GetById(int id)
        {
            try
            {
                return Ok(await _service.GetByIdAsync(id));
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { error = ex.Message });
            }
        }
    }
}
