using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Database;
using Flix.Services.Interfaces;
using FluentValidation;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
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
        public MovieService(
            FlixDbContext context,
            IMapper mapper,
            IValidator<MovieInsertRequest> insertValidator,
            IValidator<MovieUpdateRequest> updateValidator
            ) : base(context, mapper, insertValidator, updateValidator)
        {
        }

        protected override IQueryable<Movie> GetDataSource()
            => _context.Set<Movie>()
                .Include(x => x.Country)
                .Include(x => x.Language)
                .Include(x => x.Genres);

        protected override IEnumerable<Movie> ApplyFilters(IQueryable<Movie> query, MovieSearchObject? search)
        {
            if (search != null)
            {
                if (!string.IsNullOrWhiteSpace(search.Title?.Trim()))
                    query = query.Where(x => x.Title.ToLower().Contains(search.Title.Trim().ToLower()));

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

        public override async Task<MovieResponse> GetByIdAsync(int id)
        {
            var entity = await GetDataSource().FirstOrDefaultAsync(x => x.Id == id);

            if (entity is null)
                throw new KeyNotFoundException($"{nameof(Movie)} with Id {id} not found.");

            return _mapper.Map<MovieResponse>(entity);
        }

        protected override async Task BeforeInsertAsync(Movie entity, MovieInsertRequest request)
        {
            entity.Views = 0;
            entity.Genres = await LoadGenresAsync(request.GenreIds);
        }

        protected override async Task BeforeUpdateAsync(Movie entity, MovieUpdateRequest request)
        {
            if (request.GenreIds is null)
                return;

            await _context.Entry(entity).Collection(x => x.Genres).LoadAsync();

            entity.Genres.Clear();
            foreach (var genre in await LoadGenresAsync(request.GenreIds))
                entity.Genres.Add(genre);
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
                throw new KeyNotFoundException($"Genre(s) with Id {string.Join(", ", missing)} not found.");

            return genres;
        }
    }
}
