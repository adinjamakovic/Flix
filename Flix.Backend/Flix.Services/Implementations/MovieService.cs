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
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Text;

namespace Flix.Services.Implementations
{
    public class MovieService :
        BaseCRUDService<
            Movie,
            MovieResponse,
            MovieSearchObject,
            MovieInsertRequest,
            MovieUpdateRequest>,
        IMovieService
    {
        private readonly IImageStorageService _imageStorageService;
        private readonly IResponseImageUrlResolver _imageUrlResolver;
        public MovieService(
            FlixDbContext context,
            IMapper mapper,
            IValidator<MovieInsertRequest> insertValidator,
            IValidator<MovieUpdateRequest> updateValidator,
            IImageStorageService imageStorageService,
            IResponseImageUrlResolver imageUrlResolver
            ) : base(context, mapper, insertValidator, updateValidator)
        {
            _imageStorageService = imageStorageService;
            _imageUrlResolver = imageUrlResolver;
        }

        // The poster and header sit alongside the flag of the movie's country and a photo per
        // cast member, so the whole graph goes through the resolver.
        protected override MovieResponse MapToResponse(Movie entity)
        {
            var response = base.MapToResponse(entity);

            _imageUrlResolver.Resolve(response);

            return response;
        }

        protected override IQueryable<Movie> GetDataSource()
            => _context.Set<Movie>()
                .Include(x => x.Country)
                .Include(x => x.Language)
                .Include(x => x.Genres)
                .OrderBy(x => x.Id)
                .AsSplitQuery();

        protected override IEnumerable<Movie> ApplyFilters(IQueryable<Movie> query, MovieSearchObject? search)
        {
            if (search != null)
            {
                if (!string.IsNullOrWhiteSpace(search.Title?.Trim()))
                    query = query.Where(x => x.Title.ToLower().Contains(search.Title.Trim().ToLower()));

                if (!string.IsNullOrWhiteSpace(search.DirectorName?.Trim()))
                {
                    var directorName = search.DirectorName.Trim().ToLower();
                    query = query.Where(x => x.Credits.Any(c =>
                        c.Role == CastRole.Director &&
                         (c.CastMember.FirstName + " " + c.CastMember.LastName).ToLower().Contains(directorName)));
                }

                if (search.CountryId.HasValue)
                    query = query.Where(x => x.CountryId == search.CountryId.Value);

                if (search.LanguageId.HasValue)
                    query = query.Where(x => x.LanguageId == search.LanguageId.Value);

                if (search.GenreId.HasValue)
                    query = query.Where(x => x.Genres.Any(g => g.Id == search.GenreId.Value));

                if (search.IsEnabled.HasValue)
                    query = query.Where(x => x.IsEnabled == search.IsEnabled.Value);

                if (search.ReleasedAfter.HasValue)
                    query = query.Where(x => x.ReleaseDate >= search.ReleasedAfter.Value);

                if (search.ReleasedBefore.HasValue)
                    query = query.Where(x => x.ReleaseDate <= search.ReleasedBefore.Value);
            }

            return query;
        }

        protected override Task<IQueryable<Movie>> IncludeRelatedEntities(MovieSearchObject? search, IQueryable<Movie> query)
        {
            if(search?.IncludeCast == true)
                query = query.Include(x => x.Credits).ThenInclude(c => c.CastMember);
            if (search?.IncludeReviews == true)
                query = query.Include(x => x.Reviews);
            return base.IncludeRelatedEntities(search, query);
        }

        public override async Task<MovieResponse> GetByIdAsync(int id)
        {
            // A single movie always carries its cast; only the list makes it opt-in.
            var entity = await GetDataSource()
                .Include(x => x.Credits)
                .ThenInclude(c => c.CastMember)
                .FirstOrDefaultAsync(x => x.Id == id);

            if (entity is null)
                throw new ClientException($"{nameof(Movie)} with Id {id} not found.");

            return MapToResponse(entity);
        }

        protected override async Task BeforeInsertAsync(Movie entity, MovieInsertRequest request)
        {
            entity.Views = 0;
            entity.Genres = await LoadGenresAsync(request.GenreIds);
            entity.Credits = await BuildCreditsAsync(request.Credits);
            var moviePosterImagePath = await _imageStorageService.SaveAsync(ImageStorageCategory.Movie, request.MoviePoster);
            var headerImagePath = await _imageStorageService.SaveAsync(ImageStorageCategory.Movie, request.HeaderImage);
            entity.Poster = moviePosterImagePath;
            entity.HeaderImage = headerImagePath;
        }

        protected override async Task BeforeUpdateAsync(Movie entity, MovieUpdateRequest request)
        {
            if(request.HeaderImage is not null)
            {
                var headerImagePath = await _imageStorageService.ReplaceIfUploadedAsync(ImageStorageCategory.Movie, entity.HeaderImage, request.HeaderImage);
                entity.HeaderImage = headerImagePath;
            }

            if(request.MoviePoster is not null)
            {
                var moviePosterImagePath = await _imageStorageService.ReplaceIfUploadedAsync(ImageStorageCategory.Movie, entity.Poster, request.MoviePoster);
                entity.Poster = moviePosterImagePath;
            }

            if (request.Credits is not null)
                await ReplaceCreditsAsync(entity, request.Credits);

            if (request.GenreIds is null)
                return;

            await _context.Entry(entity).Collection(x => x.Genres).LoadAsync();

            entity.Genres.Clear();
            foreach (var genre in await LoadGenresAsync(request.GenreIds))
                entity.Genres.Add(genre);
        }

        // Credits are sent as the movie's whole cast list, so the old rows go and the
        // new ones take their place. They are deleted explicitly because every foreign
        // key in the model is Restrict, so orphaning them instead would throw.
        private async Task ReplaceCreditsAsync(Movie entity, List<MovieCreditRequest> credits)
        {
            var replacements = await BuildCreditsAsync(credits);

            await _context.Entry(entity).Collection(x => x.Credits).LoadAsync();

            _context.Set<MovieCast>().RemoveRange(entity.Credits.ToList());
            entity.Credits.Clear();

            foreach (var credit in replacements)
                entity.Credits.Add(credit);
        }

        // Every foreign key in the model is Restrict, so the rows the movie owns have to
        // go first or the delete is refused. These two are the movie's own composition -
        // its credits and its genre links - not content anyone else authored.
        protected override async Task BeforeDeleteAsync(Movie entity)
        {
            await _context.Entry(entity).Collection(x => x.Credits).LoadAsync();
            _context.Set<MovieCast>().RemoveRange(entity.Credits.ToList());

            var genreLinks = await _context.Set<MovieGenre>()
                .Where(mg => mg.MovieId == entity.Id)
                .ToListAsync();

            _context.Set<MovieGenre>().RemoveRange(genreLinks);
        }

        protected override async Task AfterDeleteAsync(Movie entity)
        {
            await _imageStorageService.DeleteIfExistsAsync(ImageStorageCategory.Movie, entity.Poster);
            await _imageStorageService.DeleteIfExistsAsync(ImageStorageCategory.Movie, entity.HeaderImage);
        }

        // The cast members are attached rather than just referenced by id, so the
        // response the caller gets back already carries their names and photos.
        private async Task<List<MovieCast>> BuildCreditsAsync(List<MovieCreditRequest> credits)
        {
            if (credits.Count == 0)
                return new List<MovieCast>();

            var duplicate = credits
                .GroupBy(c => new { c.CastMemberId, c.Role })
                .FirstOrDefault(g => g.Count() > 1);

            if (duplicate is not null)
                throw new ClientException(
                    $"Cast member with Id {duplicate.Key.CastMemberId} is credited as {duplicate.Key.Role} more than once.");

            var ids = credits.Select(c => c.CastMemberId).Distinct().ToList();

            var castMembers = await _context.Set<CastMember>()
                .Where(c => ids.Contains(c.Id))
                .ToDictionaryAsync(c => c.Id);

            var missing = ids.Except(castMembers.Keys).ToList();

            if (missing.Count != 0)
                throw new ClientException($"Cast member(s) with Id {string.Join(", ", missing)} not found.");

            return credits
                .Select(c => new MovieCast
                {
                    CastMemberId = c.CastMemberId,
                    CastMember = castMembers[c.CastMemberId],
                    Role = c.Role,
                    CharacterName = string.IsNullOrWhiteSpace(c.CharacterName)
                        ? null
                        : c.CharacterName.Trim(),
                    OrderOfAppearence = c.OrderOfAppearence
                })
                .ToList();
        }

        private async Task<List<Genre>> LoadGenresAsync(List<int> genreIds)
        {
            var ids = genreIds.Distinct().ToList();

            if (ids.Count == 0)
                return new List<Genre>();

            var genres = await _context.Set<Genre>()
                .Where(g => ids.Contains(g.Id))
                .ToListAsync();

            var missing = ids.Except(genres.Select(g => g.Id)).ToList();

            if (missing.Count != 0)
                throw new ClientException($"Genre(s) with Id {string.Join(", ", missing)} not found.");

            return genres;
        }
    }
}
