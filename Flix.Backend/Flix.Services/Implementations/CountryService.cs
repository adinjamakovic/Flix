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
    public class CountryService :
        BaseCRUDService<
            Country,
            CountryResponse,
            CountrySearchObject,
            CountryInsertRequest,
            CountryUpdateRequest>,
        ICountryService
    {
        public CountryService(
            FlixDbContext context,
            IMapper mapper,
            IValidator<CountryInsertRequest> insertValidator,
            IValidator<CountryUpdateRequest> updateValidator
            ) : base(context, mapper, insertValidator, updateValidator)
        {
        }

        protected override IEnumerable<Country> ApplyFilters(IQueryable<Country> query, CountrySearchObject? search)
        {
            if (search != null)
            {
                if (!string.IsNullOrWhiteSpace(search.Name?.Trim()))
                    query = query.Where(x => x.Name.ToLower().Contains(search.Name.Trim().ToLower()));

                if (!string.IsNullOrWhiteSpace(search.Code?.Trim()))
                    query = query.Where(x => x.Code != null && x.Code.ToLower() == search.Code.Trim().ToLower());
            }

            return query;
        }
    }
}
