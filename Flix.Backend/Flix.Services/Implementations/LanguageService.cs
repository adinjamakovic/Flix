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
    public class LanguageService :
        BaseCRUDService<
            Language,
            LanguageResponse,
            LanguageSearchObject,
            LanguageInsertRequest,
            LanguageUpdateRequest>,
        ILanguageService
    {
        public LanguageService(
            FlixDbContext context,
            IMapper mapper,
            IValidator<LanguageInsertRequest> insertValidator,
            IValidator<LanguageUpdateRequest> updateValidator
            ) : base(context, mapper, insertValidator, updateValidator)
        {
        }

        protected override IEnumerable<Language> ApplyFilters(IQueryable<Language> query, LanguageSearchObject? search)
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
