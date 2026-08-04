using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Database;
using Flix.Services.Interfaces;
using FluentValidation;
using MapsterMapper;
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
