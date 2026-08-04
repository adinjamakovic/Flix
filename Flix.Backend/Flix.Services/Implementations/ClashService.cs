using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Database;
using Flix.Model.Enums;
using Flix.Services.Interfaces;
using FluentValidation;
using MapsterMapper;
using System.Collections.Generic;
using System.Text;
using Microsoft.EntityFrameworkCore;

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
        protected override Task<IQueryable<Clash>> IncludeRelatedEntities(ClashSearchObject? search, IQueryable<Clash> query)
        {
            if (search?.IncludeEntries == true)
                query = query
                    .Include(c => c.Entries);

            if(search?.IncludeLists == true)
                query = query
                    .Include(c => c.Entries)
                    .ThenInclude(e => e.MovieList);

            return Task.FromResult(query);
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
