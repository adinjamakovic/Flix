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
        public MovieService(
            FlixDbContext context,
            IMapper mapper,
            IValidator<MovieInsertRequest> insertValidator,
            IValidator<MovieUpdateRequest> updateValidator,
            IImageStorageService imageStorageService
            ) : base(context, mapper, insertValidator, updateValidator)
        {
            _imageStorageService = imageStorageService;
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
            var entity = await GetDataSource().FirstOrDefaultAsync(x => x.Id == id);

            if (entity is null)
                throw new ClientException($"{nameof(Movie)} with Id {id} not found.");

            return _mapper.Map<MovieResponse>(entity);
        }

        protected override async Task BeforeInsertAsync(Movie entity, MovieInsertRequest request)
        {
            entity.Views = 0;
            entity.Genres = await LoadGenresAsync(request.GenreIds);
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

            if (request.GenreIds is null)
                return;

            await _context.Entry(entity).Collection(x => x.Genres).LoadAsync();

            entity.Genres.Clear();
            foreach (var genre in await LoadGenresAsync(request.GenreIds))
                entity.Genres.Add(genre);
        }

        protected override async Task AfterDeleteAsync(Movie entity)
        {
            await _imageStorageService.DeleteIfExistsAsync(ImageStorageCategory.Movie, entity.Poster);
            await _imageStorageService.DeleteIfExistsAsync(ImageStorageCategory.Movie, entity.HeaderImage);
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
