using Flix.CommonServices.ImageStorageService;
using Flix.Model.Enums;
using Flix.Model.Exceptions;
using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Database;
using Flix.Services.Interfaces;
using Flix.Services.StateMachines;
using FluentValidation;
using MapsterMapper;
using EasyNetQ;
using Microsoft.EntityFrameworkCore;
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
        private readonly IMovieService _movieService;
        private readonly IBus _bus;
        protected readonly IValidator<MovieRequestInsertRequest> _insertValidator;
        protected readonly IValidator<MovieRequestUpdateRequest> _updateValidator;
        public MovieRequestService(
            FlixDbContext context,
            IMapper mapper,
            IImageStorageService imageStorageService,
            ICurrentUserService currentUserService,
            IResponseImageUrlResolver imageUrlResolver,
            IActivityService activityService,
            IMovieService movieService,
            IBus bus,
            IValidator<MovieRequestInsertRequest> insertValidator,
            IValidator<MovieRequestUpdateRequest> updateValidator)
            : base(context, mapper)
        {
            _imageStorageService = imageStorageService;
            _currentUserService = currentUserService;
            _imageUrlResolver = imageUrlResolver;
            _activityService = activityService;
            _movieService = movieService;
            _bus = bus;
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
        
        public async Task<MovieRequestResponse> AdminReview(int id, MovieRequestUpdateRequest request)
        {
            await _updateValidator.ValidateAndThrowAsync(request);

            var reviewedByUserId = _currentUserService.GetUserId();

            var entity = await IncludeCreatedMovie(IncludeRequestedBy(GetDataSource()))
                .FirstOrDefaultAsync(x => x.Id == id)
                ?? throw new ClientException($"{nameof(MovieRequest)} with Id {id} not found.");

            var outcome = request.IsApproved ? MovieRequestStatus.Approved : MovieRequestStatus.Rejected;

            Transitions.MovieRequest.EnsureCanTransition(
                entity.Status,
                outcome,
                "This request is no longer pending, so it cannot be reviewed.");

            var movie = entity.CreatedMovie
                ?? throw new ClientException("This request has no movie to review.");

            var placeholderDirector = await FindPlaceholderDirectorAsync(movie);

            var keepsPlaceholder = placeholderDirector is not null
                && (request.Credits is null || request.Credits.Any(x => x.CastMemberId == placeholderDirector.Id));

            if (HasDirectorEdit(request))
            {
                if (!keepsPlaceholder)
                    throw new ClientException(
                        "Only a director the requester typed in can be modified here. Pick one from the cast list through the movie's credits instead.");

                await ApplyDirectorEditAsync(placeholderDirector!, request);
            }

            await using var transaction = await _context.Database.BeginTransactionAsync();

            await _movieService.UpdateAsync(movie.Id, request);

            movie.IsEnabled = request.IsApproved && request.IsEnabled;

            if (placeholderDirector is not null && !keepsPlaceholder)
                _context.CastMembers.Remove(placeholderDirector);

            entity.Status = outcome;
            entity.ReviewedByUserId = reviewedByUserId;
            entity.ReviewedAt = DateTime.UtcNow;
            entity.AdminComment = string.IsNullOrWhiteSpace(request.AdminComment)
                ? null
                : request.AdminComment.Trim();

            await _context.SaveChangesAsync();

            await transaction.CommitAsync();

            var response = MapToResponse(entity);

            if (request.IsApproved)
                await PublishAsync(new MovieAccepted
                {
                    Id = entity.Id,
                    Data = response
                });
            else
                await PublishAsync(new MovieRejected
                {
                    Id = entity.Id,
                    Data = response
                });

            return response;
        }

        // Withdrawing a submission belongs to whoever sent it, so this deliberately bypasses
        // GetDataSource() rather than reusing it: an admin's wider data source would otherwise
        // let them cancel somebody else's pending request instead of reviewing it.
        public async Task<MovieRequestResponse> Cancel(int id)
        {
            var userId = _currentUserService.GetUserId();

            var entity = await IncludeCreatedMovie(IncludeRequestedBy(_context.Set<MovieRequest>()))
                .FirstOrDefaultAsync(x => x.Id == id && x.RequestedByUserId == userId)
                ?? throw new ClientException($"{nameof(MovieRequest)} with Id {id} not found.");

            Transitions.MovieRequest.EnsureCanTransition(
                entity.Status,
                MovieRequestStatus.Cancelled,
                "Only a request that is still pending can be cancelled.");

            entity.Status = MovieRequestStatus.Cancelled;
            entity.ReviewedByUserId = userId;
            entity.ReviewedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            return MapToResponse(entity);
        }

        private Task PublishAsync<TMessage>(TMessage message)
            => _bus.PubSub.PublishAsync(message);

        private static bool HasDirectorEdit(MovieRequestUpdateRequest request)
            => request.DirectorFirstName is not null
                || request.DirectorLastName is not null
                || request.DirectorCountryId.HasValue
                || request.DirectorBirthDate.HasValue
                || request.DirectorBiography is not null
                || request.DirectorPhoto is not null;

        private async Task<CastMember?> FindPlaceholderDirectorAsync(Movie movie)
        {
            var director = movie.Credits.FirstOrDefault(x => x.Role == CastRole.Director)?.CastMember;

            if (director is null)
                return null;

            if (!string.IsNullOrEmpty(director.Biography) || director.BirthDate is not null || director.Photo is not null)
                return null;

            var creditCount = await _context.MovieCasts.CountAsync(x => x.CastMemberId == director.Id);

            return creditCount == 1 ? director : null;
        }

        private async Task ApplyDirectorEditAsync(CastMember director, MovieRequestUpdateRequest request)
        {
            if (request.DirectorFirstName is not null)
                director.FirstName = request.DirectorFirstName.Trim();

            if (request.DirectorLastName is not null)
                director.LastName = request.DirectorLastName.Trim();

            if (request.DirectorCountryId.HasValue)
            {
                var country = await _context.Countries.FindAsync(request.DirectorCountryId.Value)
                    ?? throw new ClientException($"Country with Id {request.DirectorCountryId.Value} not found.");

                director.CountryId = country.Id;
                director.Country = country;
            }

            if (request.DirectorBirthDate.HasValue)
                director.BirthDate = request.DirectorBirthDate.Value;

            if (request.DirectorBiography is not null)
                director.Biography = request.DirectorBiography.Trim();

            if (request.DirectorPhoto is not null)
                director.Photo = await _imageStorageService.ReplaceIfUploadedAsync(
                    ImageStorageCategory.CastMember,
                    director.Photo,
                    request.DirectorPhoto);
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

            await using var transaction = await _context.Database.BeginTransactionAsync();

            try
            {
                await _context.SaveChangesAsync();

                await _activityService.InsertAsync(requestedByUserId, new ActivityInsertRequest
                {
                    Type = ActivityType.RequestedMovie,
                    MovieId = movieEntity.Id
                });

                await transaction.CommitAsync();
            }
            catch
            {
                // The upload happens before the row exists, so a rolled back write would
                // otherwise leave a blob nothing points at.
                await _imageStorageService.DeleteIfExistsAsync(ImageStorageCategory.Movie, movieEntity.Poster);
                throw;
            }

            movieRequestEntity.RequestedBy = await _context.Users
                .Include(x => x.Country)
                .Include(x => x.Roles)
                .ThenInclude(x => x.Role)
                .FirstAsync(x => x.Id == requestedByUserId);

            var response = MapToResponse(movieRequestEntity);

            await PublishAsync(new MovieRequested
            {
                Id = movieRequestEntity.Id,
                Data = response
            });

            return response;
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
                .Include(x => x.CreatedMovie!).ThenInclude(m => m.Studios).ThenInclude(ms => ms.Studio)
                .Include(x => x.CreatedMovie!).ThenInclude(m => m.Credits).ThenInclude(c => c.CastMember);
    }
}