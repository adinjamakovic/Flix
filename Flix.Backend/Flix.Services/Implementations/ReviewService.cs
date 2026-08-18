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

        private static readonly decimal[] RatingScale =
            Enumerable.Range(1, 10).Select(step => step * 0.5m).ToArray();

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

        public async Task<PageResult<ReviewResponse>> GetLatestReviewsFromFriendsAsync(int userId)
        {
            var friendIds = await _context.UserFollows
                .Where(f => f.FollowerId == userId
                    && _context.UserFollows.Any(back =>
                        back.FollowerId == f.FollowingId && back.FollowingId == userId))
                .Select(f => f.FollowingId)
                .Distinct()
                .ToListAsync();

            if (friendIds.Count == 0)
                return new PageResult<ReviewResponse> { Items = [], TotalCount = 0 };

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

            var reviews = latest.Select(MapToResponse).ToList();

            return new PageResult<ReviewResponse>
            {
                Items = reviews,
                TotalCount = reviews.Count
            };
        }

        public async Task<ReviewCountResponse> GetReviewCountAsync(ReviewCountSearchObject? search)
        {
            if (search?.UserId is null && search?.MovieId is null)
                throw new ClientException("Either a UserId or a MovieId is required to count reviews.");

            var query = _context.Reviews.AsQueryable();

            if (search.UserId != null)
                query = query.Where(r => r.UserId == search.UserId);

            if (search.MovieId != null)
                query = query.Where(r => r.MovieId == search.MovieId);

            var counts = await query
                .GroupBy(r => r.Rating)
                .Select(g => new { Rating = g.Key, Count = g.Count() })
                .ToListAsync();

            var rated = counts.Where(c => c.Rating is not null).ToList();
            var ratedCount = rated.Sum(c => c.Count);

            return new ReviewCountResponse
            {
                UserId = search.UserId,
                MovieId = search.MovieId,
                TotalCount = counts.Sum(c => c.Count),
                UnratedCount = counts.Where(c => c.Rating is null).Sum(c => c.Count),
                AverageRating = ratedCount == 0
                    ? null
                    : Math.Round(rated.Sum(c => c.Rating!.Value * c.Count) / ratedCount, 2),
                Ratings = RatingScale
                    .Select(rating => new ReviewRatingCountResponse
                    {
                        Rating = rating,
                        Count = counts.FirstOrDefault(c => c.Rating == rating)?.Count ?? 0
                    })
                    .ToList()
            };
        }

        public async Task DeleteAsync(int id)
        {
            var entity = await _context.Reviews.FirstOrDefaultAsync(r => r.Id == id)
                ?? throw new ClientException($"{nameof(Review)} with Id {id} not found.");

            // An activity's key to its review is one of the few that cannot cascade - the
            // author the activity belongs to already reaches the same table - so the rows
            // pointing at this review have to go first or SaveChanges fails on the
            // constraint. An activity for a review that no longer exists has nothing left
            // to show anyway.
            var activities = await _context.Activities
                .Where(a => a.ReviewId == id)
                .ToListAsync();

            _context.Activities.RemoveRange(activities);
            _context.Reviews.Remove(entity);

            await _context.SaveChangesAsync();
        }
    }
}
