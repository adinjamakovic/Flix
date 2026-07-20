using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Interfaces;
using FluentValidation;
using Microsoft.AspNetCore.Mvc;

namespace Flix.WebApi.Controllers
{
    public abstract class BaseCRUDController<TResponse, TSearch, TInsertRequest, TUpdateRequest, TService>
        : BaseReadController<TResponse, TSearch, TService>
        where TService : IBaseCRUDService<TResponse, TSearch, TInsertRequest, TUpdateRequest>
        where TSearch : BaseSearchObject
    {
       protected BaseCRUDController(TService service) : base(service)
        {
        }

        [HttpPost]
        [ProducesResponseType(StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<ActionResult<TResponse>> Create([FromBody] TInsertRequest request)
        {
            var result = await _service.InsertAsync(request);
            return result;
        }

        [HttpPut("{id}")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<ActionResult<TResponse>> Update(int id, [FromBody] TUpdateRequest request)
        {
            var result = await _service.UpdateAsync(id, request);
            return result;
        }

        [HttpDelete("{id}")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Delete(int id)
        {
            await _service.DeleteAsync(id);
            return NoContent();
        }
    }
}
