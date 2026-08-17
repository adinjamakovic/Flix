using Flix.CommonServices.ImageStorageService;
using Flix.Model.Enums;
using Flix.Model.Exceptions;
using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Database;
using Flix.Services.Interfaces;
using FluentValidation;
using MapsterMapper;
using EasyNetQ;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Flix.Model.Messages;

namespace Flix.Services.Implementations
{
    public class MovieRequestService : 
        BaseReadService<
            MovieRequest, 
            MovieRequestResponse, 
            MovieRequestSearchObject>, 
        IMovieRequestService
    {
        private readonly IImageStorageService _imageStorageService;
        private readonly ICurrentUserService _currentUserService;
        private readonly IResponseImageUrlResolver _imageUrlResolver;
        private readonly IActivityService _activityService;
        private readonly string _rabbitMqConnectionString;
        protected readonly IValidator<MovieRequestInsertRequest> _insertValidator;
        protected readonly IValidator<MovieRequestUpdateRequest> _updateValidator;
        public MovieRequestService(
            FlixDbContext context,
            IMapper mapper,
            IImageStorageService imageStorageService,
            ICurrentUserService currentUserService,
            IResponseImageUrlResolver imageUrlResolver,
            IActivityService activityService,
            IConfiguration configuration,
            IValidator<MovieRequestInsertRequest> insertValidator,
            IValidator<MovieRequestUpdateRequest> updateValidator)
            : base(context, mapper)
        {
            _imageStorageService = imageStorageService;
            _currentUserService = currentUserService;
            _imageUrlResolver = imageUrlResolver;
            _activityService = activityService;
            _rabbitMqConnectionString = configuration.GetConnectionString("RabbitMQ")
                ?? throw new InvalidOperationException("Connection string 'RabbitMQ' is not configured.");
            _insertValidator = insertValidator;
            _updateValidator = updateValidator;
        }

        protected override MovieRequestResponse MapToResponse(MovieRequest entity)
        {
            var response = base.MapToResponse(entity);

            _imageUrlResolver.Resolve(response.Movie);
            _imageUrlResolver.Resolve(response.RequestedByUser);

            return response;
        }
        public Task<MovieRequestResponse> AdminReview(MovieRequestUpdateRequest request)
        {
            throw new NotImplementedException();
        }

        public async Task<CastMember?> CreateDraftDirectorAsync(string? directorName)
        {
            if (string.IsNullOrWhiteSpace(directorName))
                return null;

            // null separators splits on any whitespace, so tabs and repeated spaces are handled too
            var parts = directorName.Split((char[]?)null, StringSplitOptions.RemoveEmptyEntries);

            var fallbackCountryId = await _context.Countries
                .OrderBy(x => x.Id)
                .Select(x => (int?)x.Id)
                .FirstOrDefaultAsync();

            if (fallbackCountryId is null)
                throw new ClientException("No country exists to assign the requested director to.");

            return new CastMember
            {
                FirstName = parts[0],
                LastName = parts.Length > 1 ? string.Join(' ', parts.Skip(1)) : string.Empty,
                CountryId = fallbackCountryId.Value,
                Biography = string.Empty
            };
        }


        // Method used to store the initial MovieRequest which will be in the "Pending" state.
        // Information passed into this method is only partially correct by design, the
        // admin is the one that needs to verify the information and correct/append it during
        // the review process.
        public async Task<MovieRequestResponse> UserRequest(MovieRequestInsertRequest request)
        {
            await _insertValidator.ValidateAndThrowAsync(request);

            var requestedByUserId = _currentUserService.GetUserId();

            // Add entity which will be subject to review by admin
            var movieEntity = new Movie
            {
                Title = request.Title.Trim(),
                Description = string.IsNullOrWhiteSpace(request.Description) ?
                    string.Empty : request.Description.Trim(),
                ReleaseDate = request.DateOfRelease,
                IsEnabled = false,
                Views = 0,
                TrailerUrl = string.Empty
            };

            if (request.GenreId > 0)
            {
                var genre = await _context.Genres.FindAsync(request.GenreId)
                    ?? throw new ClientException($"Genre with Id {request.GenreId} not found.");

                movieEntity.Genres.Add(genre);
            }

            if(request.Poster != null)
                movieEntity.Poster = await _imageStorageService.SaveAsync(
                    ImageStorageCategory.Movie,
                    request.Poster);

            _context.Movies.Add(movieEntity);

            var directorName = request.DirectorName?.Trim();

            // A request without a director is legitimate - the admin fills it in during review -
            // so the credit is only written when there is somebody to credit.
            if (!string.IsNullOrEmpty(directorName))
            {
                var director = await _context.CastMembers
                    .Where(x => (x.FirstName + " " + x.LastName).Trim() == directorName)
                    .FirstOrDefaultAsync()
                    ?? await CreateDraftDirectorAsync(directorName);

                _context.MovieCasts.Add(new MovieCast
                {
                    Movie = movieEntity,
                    CastMember = director!,
                    Role = CastRole.Director
                });
            }

            var movieRequestEntity = new MovieRequest
            {
                RequestedByUserId = requestedByUserId,
                CreatedMovie = movieEntity,
                Status = MovieRequestStatus.Pending,
                CreatedAt = DateTime.UtcNow
            };

            _context.MovieRequests.Add(movieRequestEntity);

            try
            {
                await _context.SaveChangesAsync();
            }
            catch
            {
                // The upload happens before the row exists, so a failed save would otherwise
                // leave a blob nothing points at.
                await _imageStorageService.DeleteIfExistsAsync(ImageStorageCategory.Movie, movieEntity.Poster);
                throw;
            }

            await _activityService.InsertAsync(requestedByUserId, new ActivityInsertRequest
            {
                Type = ActivityType.RequestedMovie,
                MovieId = movieEntity.Id
            });

            movieRequestEntity.RequestedBy = await _context.Users
                .Include(x => x.Country)
                .Include(x => x.Roles)
                .ThenInclude(x => x.Role)
                .FirstAsync(x => x.Id == requestedByUserId);

            var bus = RabbitHutch.CreateBus(_rabbitMqConnectionString);
            
            await bus.PubSub.PublishAsync(new MovieRequested
            {
                Id = movieRequestEntity.Id,
                Data = MapToResponse(movieRequestEntity)
            });

            return MapToResponse(movieRequestEntity);
        }

        protected override IQueryable<MovieRequest> GetDataSource()
        {
            var query = _context.Set<MovieRequest>().AsQueryable();

            if (!_currentUserService.IsAdmin)
            {
                var userId = _currentUserService.GetUserId();
                query = query.Where(x => x.RequestedByUserId == userId);
            }

            return query
                .OrderByDescending(x => x.CreatedAt)
                .ThenByDescending(x => x.Id)
                .AsSplitQuery();
        }

        protected override IEnumerable<MovieRequest> ApplyFilters(IQueryable<MovieRequest> query, MovieRequestSearchObject? search)
        {
            if (search is null)
                return query;

            if (search.status.HasValue)
                query = query.Where(x => x.Status == search.status.Value);

            return query;
        }

        protected override Task<IQueryable<MovieRequest>> IncludeRelatedEntities(MovieRequestSearchObject? search, IQueryable<MovieRequest> query)
        {
            if (search?.IncludeUser == true)
                query = IncludeRequestedBy(query);

            if (search?.IncludeMovie == true)
                query = IncludeCreatedMovie(query);

            return base.IncludeRelatedEntities(search, query);
        }

        public override async Task<MovieRequestResponse> GetByIdAsync(int id)
        {
            var entity = await IncludeCreatedMovie(IncludeRequestedBy(GetDataSource()))
                .FirstOrDefaultAsync(x => x.Id == id)
                ?? throw new ClientException($"{nameof(MovieRequest)} with Id {id} not found.");

            return MapToResponse(entity);
        }

        private static IQueryable<MovieRequest> IncludeRequestedBy(IQueryable<MovieRequest> query)
            => query
                .Include(x => x.RequestedBy).ThenInclude(u => u.Country)
                .Include(x => x.RequestedBy).ThenInclude(u => u.Roles).ThenInclude(r => r.Role);

        private static IQueryable<MovieRequest> IncludeCreatedMovie(IQueryable<MovieRequest> query)
            => query
                .Include(x => x.CreatedMovie!).ThenInclude(m => m.Country)
                .Include(x => x.CreatedMovie!).ThenInclude(m => m.Language)
                .Include(x => x.CreatedMovie!).ThenInclude(m => m.Genres)
                .Include(x => x.CreatedMovie!).ThenInclude(m => m.Credits).ThenInclude(c => c.CastMember);
    }
}