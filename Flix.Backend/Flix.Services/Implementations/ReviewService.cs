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
        private const int LatestFromFriendsCount = 10;

        private readonly IResponseImageUrlResolver _imageUrlResolver;

        public ReviewService(FlixDbContext context, IMapper mapper, IResponseImageUrlResolver imageUrlResolver)
            : base(context, mapper)
        {
            _imageUrlResolver = imageUrlResolver;
        }

        protected override IQueryable<Review> GetDataSource()
        {
            return _context.Reviews
                .OrderByDescending(x=> x.CreatedAt);
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

            if(search.UserId != null)
                query = query.Where(x=>x.UserId == search.UserId);

            if(search.MovieId != null)
                query = query.Where(x => x.MovieId == search.MovieId);

            if(search.FollowedByUserId != null)
                query = query.Where(r => r.User.Followers.Any(x=> x.Follower.Id == search.FollowedByUserId));

            return query;
        }

        public async Task<List<ReviewResponse>> GetLatestReviewsFromFriendsAsync(int userId)
        {
            var friendIds = await _context.UserFollows
                .Where(f => f.FollowerId == userId
                    && _context.UserFollows.Any(back =>
                        back.FollowerId == f.FollowingId && back.FollowingId == userId))
                .Select(f => f.FollowingId)
                .Distinct()
                .ToListAsync();

            if (friendIds.Count == 0)
                return new List<ReviewResponse>();

            var latest = await _context.Reviews
                .Include(r => r.User)
                .Include(r => r.Movie)
                .Where(r => friendIds.Contains(r.UserId) && r.Movie.IsEnabled)
                .Where(r => !_context.Reviews.Any(newer =>
                    newer.UserId == r.UserId
                    && newer.Movie.IsEnabled
                    && (newer.CreatedAt > r.CreatedAt
                        || (newer.CreatedAt == r.CreatedAt && newer.Id > r.Id))))
                .OrderByDescending(r => r.CreatedAt)
                .ThenByDescending(r => r.Id)
                .Take(LatestFromFriendsCount)
                .ToListAsync();

            return latest.Select(MapToResponse).ToList();
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
