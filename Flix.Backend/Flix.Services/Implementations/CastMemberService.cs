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
    public class CastMemberService :
        BaseCRUDService<
            CastMember, 
            CastMemberResponse, 
            CastMemberSearchObject, 
            CastMemberInsertRequest, 
            CastMemberUpdateRequest>, 
        ICastMemberService
    {
        public CastMemberService(
            FlixDbContext context,
            IMapper mapper,
            IValidator<CastMemberInsertRequest> insertValidator,
            IValidator<CastMemberUpdateRequest> updateValidator
            ) : base(context, mapper, insertValidator, updateValidator)
        { 
        }

        protected override IEnumerable<CastMember> ApplyFilters(IQueryable<CastMember> query, CastMemberSearchObject? search)
        {
            if (search != null)
            {
                if (!string.IsNullOrWhiteSpace(search.FirstName?.Trim()))
                    query = query.Where(x => x.FirstName.ToLower().Contains(search.FirstName.Trim().ToLower()));
                
                if(!string.IsNullOrWhiteSpace(search.LastName?.Trim()))
                    query = query.Where(x => x.LastName.ToLower().Contains(search.LastName.Trim().ToLower()));

                if(search!.CountryId.HasValue)
                    query = query.Where(x => x.CountryId == search.CountryId.Value);

                if(search.MovieId.HasValue)
                    query = query.Where(x => x.MovieCredits.Any(mc => mc.MovieId == search.MovieId));
            }

            return query;
        }
    }
}
