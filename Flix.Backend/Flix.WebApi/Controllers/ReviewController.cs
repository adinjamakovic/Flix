using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Implementations;
using Flix.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace Flix.WebApi.Controllers
{
    public class ReviewController : BaseReadController<ReviewResponse, ReviewSearchObject, IReviewService>
    {
        public ReviewController(IReviewService service) : base(service)
        {
        }
    }
}
