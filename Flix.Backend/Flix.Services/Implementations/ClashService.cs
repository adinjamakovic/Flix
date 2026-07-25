using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Database;
using Flix.Services.Enums;
using Flix.Services.Interfaces;
using FluentValidation;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Text;

namespace Flix.Services.Implementations
{
    public class ClashService :
        BaseCRUDService<Clash, ClashResponse, ClashSearchObject, ClashInsertRequest, ClashUpdateRequest>,
        IClashService
    {
        public ClashService(
            FlixDbContext context,
            IMapper mapper,
            IValidator<ClashInsertRequest> insertValidator,
            IValidator<ClashUpdateRequest> updateValidator)
            : base(context, mapper, insertValidator, updateValidator)
        {            
        }

        protected override IEnumerable<Clash> ApplyFilters(IQueryable<Clash> query, ClashSearchObject? search)
        {
            if(search != null)
            {
                if (!string.IsNullOrWhiteSpace(search.Name))
                {
                    query = query.Where(c => c.Name.ToLower().Contains(search.Name.ToLower()));
                }
                if (search.Status.HasValue)
                {
                    query = query.Where(c => c.Status == (ClashStatus)search.Status.Value);
                }
            }   
            return query;
        }
    }
}
