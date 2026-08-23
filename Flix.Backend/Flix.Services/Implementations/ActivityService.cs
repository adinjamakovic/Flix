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
    public class ActivityService :
        BaseReadService<
            Activity,
            ActivityResponse,
            ActivitySearchObject>,
        IActivityService
    {
        private readonly ICurrentUserService _currentUserService;
        private readonly IResponseImageUrlResolver _imageUrlResolver;
        protected readonly IValidator<ActivityInsertRequest> _insertValidator;

        public ActivityService(
            FlixDbContext context,
            IMapper mapper,
            ICurrentUserService currentUserService,
            IResponseImageUrlResolver imageUrlResolver,
            IValidator<ActivityInsertRequest> insertValidator)
            : base(context, mapper)
        {
            _currentUserService = currentUserService;
            _imageUrlResolver = imageUrlResolver;
            _insertValidator = insertValidator;
        }

        public Task<ActivityResponse> InsertAsync(ActivityInsertRequest request)
            => InsertAsync(_currentUserService.GetUserId(), request);

        public async Task<ActivityResponse> InsertAsync(int userId, ActivityInsertRequest request)
        {
            await _insertValidator.ValidateAndThrowAsync(request);

            await EnsureReferencesExistAsync(userId, request);

            var entity = new Activity
            {
                UserId = userId,
                Type = request.Type,
                MovieId = request.MovieId,
                ReviewId = request.ReviewId,
                ClashId = request.ClashId,
                MovieListId = request.MovieListId,
                TargetUserId = request.TargetUserId,
                CreatedAt = DateTime.UtcNow
            };

            _context.Activities.Add(entity);

            await _context.SaveChangesAsync();

            return await GetByIdAsync(entity.Id);
        }

        protected override IQueryable<Activity> GetDataSource()
        {
            return _context.Set<Activity>()
                .Include(x => x.User).ThenInclude(u => u.Country)
                .Include(x => x.User).ThenInclude(u => u.Roles).ThenInclude(r => r.Role)
                .Include(x => x.TargetUser!).ThenInclude(u => u.Country)
                .Include(x => x.Movie!).ThenInclude(m => m.Country)
                .Include(x => x.Movie!).ThenInclude(m => m.Language)
                .Include(x => x.Movie!).ThenInclude(m => m.Genres)
                .Include(x => x.Review!).ThenInclude(r => r.User)
                .Include(x => x.Review!).ThenInclude(r => r.Movie)
                .Include(x => x.Clash!)
                .Include(x => x.MovieList!)
                .OrderByDescending(x => x.CreatedAt)
                .ThenByDescending(x => x.Id)
                .AsSplitQuery();
        }

        protected override ActivityResponse MapToResponse(Activity entity)
        {
            var response = base.MapToResponse(entity);

            _imageUrlResolver.Resolve(response.User);
            _imageUrlResolver.Resolve(response.TargetUser);
            _imageUrlResolver.Resolve(response.Movie);
            _imageUrlResolver.Resolve(response.Review);
            _imageUrlResolver.Resolve(response.Clash);

            return response;
        }

        protected override IEnumerable<Activity> ApplyFilters(IQueryable<Activity> query, ActivitySearchObject? search)
        {
            if (search is null)
                return query;

            if (search.UserId.HasValue)
                query = query.Where(x => x.UserId == search.UserId.Value);

            if (search.ActivityType.HasValue)
                query = query.Where(x => x.Type == search.ActivityType.Value);

            if (search.MovieId.HasValue)
                query = query.Where(x => x.MovieId == search.MovieId.Value);

            if (search.ClashId.HasValue)
                query = query.Where(x => x.ClashId == search.ClashId.Value);

            if (search.TargetUserId.HasValue)
                query = query.Where(x => x.TargetUserId == search.TargetUserId.Value);

            return query;
        }

        public override async Task<ActivityResponse> GetByIdAsync(int id)
        {
            var entity = await GetDataSource().FirstOrDefaultAsync(x => x.Id == id)
                ?? throw new ClientException($"{nameof(Activity)} with Id {id} not found.");

            return MapToResponse(entity);
        }

        public async Task<PageResult<ActivityResponse>> GetFromFollowersAsync(ActivitySearchObject? search = null)
        {
            var userId = _currentUserService.GetUserId();

            var query = GetDataSource()
                .Where(x => x.User.Followers.Any(f => f.FollowerId == userId))
                .Where(x => x.MovieId == null || x.Movie!.IsEnabled);

            return await GetPagedAsync(query, search);
        }

        public async Task<PageResult<ActivityResponse>> GetFromSelfAsync(ActivitySearchObject? search = null)
        {
            var userId = _currentUserService.GetUserId();

            return await GetPagedAsync(GetDataSource().Where(x => x.UserId == userId), search);
        }

        private async Task<PageResult<ActivityResponse>> GetPagedAsync(IQueryable<Activity> query, ActivitySearchObject? search)
        {
            query = ApplyFilters(query, search).AsQueryable();

            int? totalCount = null;

            if (search?.IncludeTotalCount ?? false)
                totalCount = await query.CountAsync();

            if (search?.Page is int page && search.PageSize is int size)
                query = query.Skip((page - 1) * size);

            if (search?.PageSize is int pageSize)
                query = query.Take(pageSize);

            var entities = await query.ToListAsync();

            return new PageResult<ActivityResponse>
            {
                Items = entities.Select(MapToResponse).ToList(),
                TotalCount = totalCount
            };
        }

        private async Task EnsureReferencesExistAsync(int userId, ActivityInsertRequest request)
        {
            if (!await _context.Users.AnyAsync(x => x.Id == userId))
                throw new ClientException($"User with Id {userId} not found.");

            if (request.MovieId is int movieId && !await _context.Movies.AnyAsync(x => x.Id == movieId))
                throw new ClientException($"Movie with Id {movieId} not found.");

            if (request.ReviewId is int reviewId && !await _context.Reviews.AnyAsync(x => x.Id == reviewId))
                throw new ClientException($"Review with Id {reviewId} not found.");

            if (request.ClashId is int clashId && !await _context.Clashes.AnyAsync(x => x.Id == clashId))
                throw new ClientException($"Clash with Id {clashId} not found.");

            if (request.MovieListId is int movieListId && !await _context.MovieLists.AnyAsync(x => x.Id == movieListId))
                throw new ClientException($"MovieList with Id {movieListId} not found.");

            if (request.TargetUserId is int targetUserId && !await _context.Users.AnyAsync(x => x.Id == targetUserId))
                throw new ClientException($"User with Id {targetUserId} not found.");
        }
    }
}
