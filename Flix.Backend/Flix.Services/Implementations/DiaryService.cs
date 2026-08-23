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
    public class DiaryService : IDiaryService
    {
        private readonly FlixDbContext _context;
        private readonly IMapper _mapper;
        private readonly ICurrentUserService _currentUserService;
        private readonly IResponseImageUrlResolver _imageUrlResolver;
        private readonly IActivityService _activityService;
        private readonly IListService _listService;
        private readonly IValidator<DiaryInsertRequest> _insertValidator;

        public DiaryService(
            FlixDbContext context,
            IMapper mapper,
            ICurrentUserService currentUserService,
            IResponseImageUrlResolver imageUrlResolver,
            IActivityService activityService,
            IListService listService,
            IValidator<DiaryInsertRequest> insertValidator)
        {
            _context = context;
            _mapper = mapper;
            _currentUserService = currentUserService;
            _imageUrlResolver = imageUrlResolver;
            _activityService = activityService;
            _listService = listService;
            _insertValidator = insertValidator;
        }

        public async Task<PageResult<ReviewResponse>> GetUserDiaryAsync(DiarySearchObject? search)
        {
            if (search?.UserId is not int userId)
                throw new ClientException("A diary is always read for one user, so a UserId is required.");

            var query = _context.Reviews
                .Include(x => x.Movie)
                .Where(x => x.IsDiaryEntry && x.UserId == userId);

            query = query
                .OrderByDescending(x => x.WatchedOn ?? x.CreatedAt)
                .ThenByDescending(x => x.Id);

            int? totalCount = null;

            if (search.IncludeTotalCount ?? false)
                totalCount = await query.CountAsync();

            if (search.Page is int page && search.PageSize is int size)
                query = query.Skip((page - 1) * size);

            if (search.PageSize is int pageSize)
                query = query.Take(pageSize);

            var entities = await query.ToListAsync();

            return new PageResult<ReviewResponse>
            {
                Items = entities.Select(MapToResponse).ToList(),
                TotalCount = totalCount
            };
        }

        public async Task<ReviewResponse> AddToDiaryAsync(DiaryInsertRequest request)
        {
            await _insertValidator.ValidateAndThrowAsync(request);

            var userId = _currentUserService.GetUserId();

            var movie = await _context.Movies.FirstOrDefaultAsync(x => x.Id == request.MovieId)
                ?? throw new ClientException($"Movie with Id {request.MovieId} not found.");

            if (!movie.IsEnabled)
                throw new ClientException("This movie cannot be logged.");

            var watchedOn = request.WatchedOn ?? DateTime.UtcNow;

            var isRewatch = request.IsRewatch || await HasWatchedBeforeAsync(userId, movie.Id, watchedOn);

            var entity = await _context.Reviews.FirstOrDefaultAsync(x => x.UserId == userId
                && x.MovieId == movie.Id
                && !x.IsDiaryEntry);

            var isNewEntry = entity is null;

            if (entity is null)
            {
                entity = new Review
                {
                    UserId = userId,
                    MovieId = movie.Id,
                    CreatedAt = DateTime.UtcNow
                };

                _context.Reviews.Add(entity);
            }
            else
            {
                entity.UpdatedAt = DateTime.UtcNow;
            }

            entity.Rating = request.Rating;
            entity.IsLiked = request.IsLiked;
            entity.Content = request.Content?.Trim() ?? string.Empty;
            entity.ContainsSpoilers = request.ContainsSpoilers;
            entity.IsDiaryEntry = true;
            entity.IsRewatch = isRewatch;
            entity.WatchedOn = watchedOn;

            await _context.SaveChangesAsync();

            if (isNewEntry || !await HasActivityAsync(entity.Id, ActivityType.WatchedMovie))
                await LogAsync(userId, entity, ActivityType.WatchedMovie);

            if (entity.Content.Length > 0 && !await HasActivityAsync(entity.Id, ActivityType.ReviewedMovie))
                await LogAsync(userId, entity, ActivityType.ReviewedMovie);

            if (entity.IsLiked && !await HasActivityAsync(entity.Id, ActivityType.LikedMovie))
                await LogAsync(userId, entity, ActivityType.LikedMovie);

            await _listService.RemoveIfAddedToWatchlistAsync(movie.Id);

            await _context.Entry(entity).Reference(x => x.Movie).LoadAsync();

            return MapToResponse(entity);
        }

        private Task LogAsync(int userId, Review entity, ActivityType type)
        {
            return _activityService.InsertAsync(userId, new ActivityInsertRequest
            {
                Type = type,
                MovieId = entity.MovieId,
                ReviewId = entity.Id
            });
        }

        private Task<bool> HasActivityAsync(int reviewId, ActivityType type)
        {
            return _context.Activities.AnyAsync(x => x.ReviewId == reviewId && x.Type == type);
        }

        private Task<bool> HasWatchedBeforeAsync(int userId, int movieId, DateTime watchedOn)
        {
            return _context.Reviews.AnyAsync(x => x.UserId == userId
                && x.MovieId == movieId
                && x.IsDiaryEntry
                && (x.WatchedOn ?? x.CreatedAt) <= watchedOn);
        }

        // The entry owns no image, but the movie's poster and the author's avatar are stored
        // blob paths until they go through the resolver.
        private ReviewResponse MapToResponse(Review entity)
        {
            var response = _mapper.Map<ReviewResponse>(entity);

            _imageUrlResolver.Resolve(response);

            return response;
        }
    }
}
