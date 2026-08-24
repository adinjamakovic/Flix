using Flix.Model.Enums;
using Flix.Model.Exceptions;
using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Database;
using Flix.Services.Interfaces;
using FluentValidation;
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
        private readonly ICurrentUserService _currentUserService;
        private readonly IListService _listService;
        private readonly IActivityService _activityService;
        private readonly IValidator<ReviewUpsertRequest> _upsertValidator;

        public ReviewService(
            FlixDbContext context,
            IMapper mapper,
            IResponseImageUrlResolver imageUrlResolver,
            ICurrentUserService currentUserService,
            IListService listService,
            IActivityService activityService,
            IValidator<ReviewUpsertRequest> upsertValidator)
            : base(context, mapper)
        {
            _imageUrlResolver = imageUrlResolver;
            _currentUserService = currentUserService;
            _listService = listService;
            _activityService = activityService;
            _upsertValidator = upsertValidator;
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

        public async Task<MovieUserStateResponse> GetMovieStateAsync(int movieId)
        {
            var userId = _currentUserService.GetUserId();

            var rows = await GetUserRowsAsync(userId, movieId);
            var opinion = PickOpinion(rows);

            return new MovieUserStateResponse
            {
                MovieId = movieId,
                IsWatched = rows.Count > 0,
                IsLiked = opinion?.IsLiked ?? false,
                Rating = opinion?.Rating,
                IsInWatchlist = await _listService.IsInWatchlistAsync(movieId),
                DiaryEntryCount = rows.Count(x => x.IsDiaryEntry)
            };
        }

        public async Task<MovieUserStateResponse> UpsertStandingReviewAsync(ReviewUpsertRequest request)
        {
            await _upsertValidator.ValidateAndThrowAsync(request);

            var userId = _currentUserService.GetUserId();

            var movie = await _context.Movies.FirstOrDefaultAsync(x => x.Id == request.MovieId)
                ?? throw new ClientException($"Movie with Id {request.MovieId} not found.");

            if (!movie.IsEnabled)
                throw new ClientException("This movie cannot be rated.");

            if (!request.IsWatched && !request.IsLiked && request.Rating is null)
                return await ClearOpinionAsync(userId, movie.Id);

            var opinion = PickOpinion(await GetUserRowsAsync(userId, movie.Id));

            var wasWatched = opinion is not null;
            var wasLiked = opinion?.IsLiked ?? false;

            if (opinion is null)
            {
                opinion = new Review
                {
                    UserId = userId,
                    MovieId = movie.Id,
                    IsDiaryEntry = false,
                    CreatedAt = DateTime.UtcNow
                };

                _context.Reviews.Add(opinion);

                movie.Views++;
            }
            else
            {
                opinion.UpdatedAt = DateTime.UtcNow;
            }

            opinion.IsLiked = request.IsLiked;
            opinion.Rating = request.Rating;

            await _context.SaveChangesAsync();

            if (!wasWatched)
            {
                await _activityService.InsertAsync(userId, new ActivityInsertRequest
                {
                    Type = ActivityType.WatchedMovie,
                    MovieId = movie.Id,
                    ReviewId = opinion.Id
                });

                await _listService.RemoveIfAddedToWatchlistAsync(movie.Id);
            }

            if (request.IsLiked && !wasLiked)
                await _activityService.InsertAsync(userId, new ActivityInsertRequest
                {
                    Type = ActivityType.LikedMovie,
                    MovieId = movie.Id,
                    ReviewId = opinion.Id
                });

            return await GetMovieStateAsync(movie.Id);
        }

        private async Task<MovieUserStateResponse> ClearOpinionAsync(int userId, int movieId)
        {
            var rows = await GetUserRowsAsync(userId, movieId);

            // A diary entry is the record of a viewing, and a written review with it. Neither is
            // something a toggle gets to throw away.
            if (rows.Any(x => x.IsDiaryEntry))
                throw new ClientException(
                    "This movie is in your diary, so it stays watched. Delete the diary entries to unmark it.");

            var standing = rows.FirstOrDefault(x => !x.IsDiaryEntry);

            if (standing is not null)
                await DeleteAsync(standing.Id);

            return await GetMovieStateAsync(movieId);
        }

        private Task<List<Review>> GetUserRowsAsync(int userId, int movieId)
        {
            return _context.Reviews
                .Where(x => x.UserId == userId && x.MovieId == movieId)
                .ToListAsync();
        }

        private static Review? PickOpinion(List<Review> rows)
        {
            return rows.FirstOrDefault(x => !x.IsDiaryEntry)
                ?? rows
                    .OrderByDescending(x => x.WatchedOn ?? x.CreatedAt)
                    .ThenByDescending(x => x.Id)
                    .FirstOrDefault();
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

            var movie = await _context.Movies.FirstOrDefaultAsync(x => x.Id == entity.MovieId);

            if (movie is not null && movie.Views > 0)
                movie.Views--;

            await _context.SaveChangesAsync();
        }
    }
}
