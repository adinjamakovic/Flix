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
    public class GenreService :
        BaseCRUDService<
            Genre,
            GenreResponse,
            GenreSearchObject,
            GenreInsertRequest,
            GenreUpdateRequest>,
        IGenreService
    {
        public GenreService(
            FlixDbContext context,
            IMapper mapper,
            IValidator<GenreInsertRequest> insertValidator,
            IValidator<GenreUpdateRequest> updateValidator
            ) : base(context, mapper, insertValidator, updateValidator)
        {
        }

        public async Task<List<GenrePercentageResponse>> GetGenrePercentages()
        {
            var counts = await _context.MovieGenres
                .Where(x => x.Movie.IsEnabled)
                .GroupBy(x => x.GenreId)
                .Select(x => new { GenreId = x.Key, Count = x.Count() })
                .ToDictionaryAsync(x => x.GenreId, x => x.Count);

            var total = counts.Values.Sum();

            var genres = await _context.Genres.ToListAsync();

            return genres
                .OrderByDescending(x => counts.GetValueOrDefault(x.Id))
                .ThenBy(x => x.Name)
                .Select(x => new GenrePercentageResponse
                {
                    Genre = MapToResponse(x),
                    Percentage = total == 0 ? 0m : Math.Round(counts.GetValueOrDefault(x.Id) * 100m / total, 2)
                })
                .ToList();
        }

        protected override async Task BeforeInsertAsync(Genre entity, GenreInsertRequest request)
        {
            await EnsureNameIsAvailableAsync(entity);
        }

        protected override async Task BeforeUpdateAsync(Genre entity, GenreUpdateRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.Name))
                return;

            await EnsureNameIsAvailableAsync(entity);
        }

        private async Task EnsureNameIsAvailableAsync(Genre entity)
        {
            entity.Name = entity.Name.Trim();

            if (await _context.Genres.AnyAsync(x => x.Id != entity.Id && x.Name == entity.Name))
                throw new ClientException($"Genre '{entity.Name}' already exists.");
        }

        protected override IEnumerable<Genre> ApplyFilters(IQueryable<Genre> query, GenreSearchObject? search)
        {
            if (search != null)
            {
                if (!string.IsNullOrWhiteSpace(search.Name?.Trim()))
                    query = query.Where(x => x.Name.ToLower().Contains(search.Name.Trim().ToLower()));
            }

            return query;
        }
    }
}
