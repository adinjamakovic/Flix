using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Database;
using Flix.Services.Interfaces;
using FluentValidation;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Text;

namespace Flix.Services.Implementations
{
    public class StudioService :
        BaseCRUDService<
            Studio,
            StudioResponse,
            StudioSearchObject,
            StudioInsertRequest,
            StudioUpdateRequest>,
        IStudioService
    {
        public StudioService(
            FlixDbContext context,
            IMapper mapper,
            IValidator<StudioInsertRequest> insertValidator,
            IValidator<StudioUpdateRequest> updateValidator
            ) : base(context, mapper, insertValidator, updateValidator)
        {
        }

        protected override IEnumerable<Studio> ApplyFilters(IQueryable<Studio> query, StudioSearchObject? search)
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
