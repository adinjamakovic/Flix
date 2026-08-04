using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Database;
using Flix.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;

namespace Flix.Services.Implementations
{
    public class ReviewService : BaseReadService<Review, ReviewResponse, ReviewSearchObject>, IReviewService
    {
        public ReviewService(FlixDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override Task<IQueryable<Review>> IncludeRelatedEntities(ReviewSearchObject? search, IQueryable<Review> query)
        {
            if(search?.IncludeMovie == true)
                query = query.Include(r => r.Movie);

            if(search?.IncludeUser == true)
                query = query.Include(r => r.User);

            return base.IncludeRelatedEntities(search, query);
        }

        protected override IEnumerable<Review> ApplyFilters(IQueryable<Review> query, ReviewSearchObject? search)
        {
            if (search is null)
                return query;

            if(search.Username != null)
                query = query.Where(r => r.User.Username.ToLower().Contains(search.Username.ToLower()));

            if(search.MovieTitle != null)
                query = query.Where(r => r.Movie.Title.ToLower().Contains(search.MovieTitle.ToLower()));

            if(search.ReviewRating != null)
                query = query.Where(r => r.Rating == search.ReviewRating);

            return query;
        }
    }
}
