using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Implementations;
using Flix.Services.Interfaces;
using Flix.WebApi.Filters;
using Microsoft.AspNetCore.Mvc;

namespace Flix.WebApi.Controllers
{
    public class ListController
        : BaseCRUDController<ListResponse, ListSearchObject, ListInsertRequest, ListUpdateRequest, IListService>
    {

        public ListController(IListService listService) : base(listService)
        {
        }

        [HttpPost("AddToList")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> AddToList(AddToListRequest request)
        {
            await _service.AddToList(request);
            return NoContent();
        }

        [HttpDelete("Watchlist/{movieId}")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> RemoveFromWatchlist(int movieId)
        {
            await _service.RemoveIfAddedToWatchlistAsync(movieId);
            return NoContent();
        }
    }
}