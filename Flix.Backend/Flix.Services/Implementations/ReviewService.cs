using Flix.Model.Exceptions;
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
        private readonly IResponseImageUrlResolver _imageUrlResolver;

        public ReviewService(FlixDbContext context, IMapper mapper, IResponseImageUrlResolver imageUrlResolver)
            : base(context, mapper)
        {
            _imageUrlResolver = imageUrlResolver;
        }

        // A review owns no image of its own, but it carries the author and the movie, and both
        // of those do.
        protected override ReviewResponse MapToResponse(Review entity)
        {
            var response = base.MapToResponse(entity);

            _imageUrlResolver.Resolve(response);

            return response;
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

        public async Task DeleteAsync(int id)
        {
            var entity = await _context.Reviews.FirstOrDefaultAsync(r => r.Id == id)
                ?? throw new ClientException($"{nameof(Review)} with Id {id} not found.");

            // Every foreign key in the model is Restrict, so the activity rows pointing at
            // this review have to go first or SaveChanges fails on the constraint. An
            // activity for a review that no longer exists has nothing left to show anyway.
            var activities = await _context.Activities
                .Where(a => a.ReviewId == id)
                .ToListAsync();

            _context.Activities.RemoveRange(activities);
            _context.Reviews.Remove(entity);

            await _context.SaveChangesAsync();
        }
    }
}
