using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Implementations;
using Flix.Services.Interfaces;
using Flix.WebApi.Filters;
using Microsoft.AspNetCore.Mvc;

namespace Flix.WebApi.Controllers
{
    public class ReviewController : BaseReadController<ReviewResponse, ReviewSearchObject, IReviewService>
    {
        public ReviewController(IReviewService service) : base(service)
        {
        }

        // Read-only base, so delete is declared here rather than inherited. Moderating
        // somebody else's review is an admin action - a user editing their own review
        // is not this endpoint.
        [HttpDelete("{id}")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [Authorization("Admin")]
        public async Task<IActionResult> Delete(int id)
        {
            await _service.DeleteAsync(id);
            return NoContent();
        }
    }
}
