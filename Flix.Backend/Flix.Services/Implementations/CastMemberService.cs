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
    public class CastMemberService :
        BaseCRUDService<
            CastMember, 
            CastMemberResponse, 
            CastMemberSearchObject, 
            CastMemberInsertRequest, 
            CastMemberUpdateRequest>, 
        ICastMemberService
    {
        private readonly IImageStorageService _imageStorageService;

        public CastMemberService(
            FlixDbContext context,
            IMapper mapper,
            IValidator<CastMemberInsertRequest> insertValidator,
            IValidator<CastMemberUpdateRequest> updateValidator,
            IImageStorageService imageStorageService
            ) : base(context, mapper, insertValidator, updateValidator)
        {
            _imageStorageService = imageStorageService;
        }

        protected override async Task BeforeInsertAsync(CastMember entity, CastMemberInsertRequest request)
        {
            entity.Photo = await _imageStorageService.SaveAsync(ImageStorageCategory.CastMember, request.Photo);
        }

        protected override async Task BeforeUpdateAsync(CastMember entity, CastMemberUpdateRequest request)
        {
            if (request.Photo is null)
                return;

            entity.Photo = await _imageStorageService.ReplaceIfUploadedAsync(
                ImageStorageCategory.CastMember,
                entity.Photo,
                request.Photo);
        }

        protected override async Task AfterDeleteAsync(CastMember entity)
        {
            await _imageStorageService.DeleteIfExistsAsync(ImageStorageCategory.CastMember, entity.Photo);
        }

        // Skip/Take run on the server, so paging needs a stable ordering to avoid
        // repeating or dropping rows between pages.
        protected override IQueryable<CastMember> GetDataSource()
            => _context.Set<CastMember>()
                .OrderBy(x => x.LastName)
                .ThenBy(x => x.FirstName)
                .ThenBy(x => x.Id);

        protected override IEnumerable<CastMember> ApplyFilters(IQueryable<CastMember> query, CastMemberSearchObject? search)
        {
            if (search != null)
            {
                if (!string.IsNullOrWhiteSpace(search.Name?.Trim()))
                    query = query.Where(x => (String.Concat(x.FirstName, " ", x.LastName)).ToLower().Contains(search.Name.Trim().ToLower()));

                if (search.CountryId.HasValue)
                    query = query.Where(x => x.CountryId == search.CountryId.Value);

                query = ApplyCreditFilters(query, search);
            }

            return query;
        }

        // Role and movie both filter the same credit rows, so they are matched against a
        // single credit rather than as two independent Any() clauses — searching for
        // "Director on movie 5" must not match someone who directed movie 9 and acted in 5.
        private static IQueryable<CastMember> ApplyCreditFilters(IQueryable<CastMember> query, CastMemberSearchObject search)
        {
            var roles = NormalizeRoles(search.Roles);
            var movieId = search.MovieId;

            if (roles is null && movieId is null)
                return query;

            if (roles is null)
                return query.Where(x => x.Credits.Any(mc => mc.MovieId == movieId!.Value));

            if (movieId is null)
                return query.Where(x => x.Credits.Any(mc => roles.Contains(mc.Role)));

            return query.Where(x => x.Credits.Any(mc => mc.MovieId == movieId.Value && roles.Contains(mc.Role)));
        }

        // Drops duplicates and undefined enum values, and treats an empty list as "no role
        // filter" so a cleared multi-select does not silently return zero rows.
        private static List<CastRole>? NormalizeRoles(List<CastRole>? roles)
        {
            if (roles is null || roles.Count == 0)
                return null;

            var normalized = roles.Where(Enum.IsDefined).Distinct().ToList();

            if (normalized.Count == 0)
                throw new ClientException($"'{string.Join(", ", roles)}' is not a valid cast role.");

            return normalized;
        }

        protected override Task<IQueryable<CastMember>> IncludeRelatedEntities(CastMemberSearchObject? search, IQueryable<CastMember> query)
        {
            if (search?.IncludeCountry == true)
                query = query.Include(x => x.Country);

            // Filtering by role and getting back an empty Roles list would be confusing, 
            // so a role filter opts in for free.
            if (search?.IncludeRoles == true || search?.Roles?.Count > 0)
                query = query.Include(x => x.Credits);

            return base.IncludeRelatedEntities(search, query);
        }
    }
}
