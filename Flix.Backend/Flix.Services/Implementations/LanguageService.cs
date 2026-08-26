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

        protected override async Task BeforeInsertAsync(Language entity, LanguageInsertRequest request)
        {
            await EnsureIsUniqueAsync(entity);
        }

        protected override async Task BeforeUpdateAsync(Language entity, LanguageUpdateRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.Name))
                return;

            await EnsureIsUniqueAsync(entity);
        }

        private async Task EnsureIsUniqueAsync(Language entity)
        {
            entity.Name = entity.Name.Trim();
            entity.Code = entity.Code?.Trim();

            if (await _context.Languages.AnyAsync(x => x.Id != entity.Id && x.Name == entity.Name))
                throw new ClientException($"Language '{entity.Name}' already exists.");

            if (string.IsNullOrEmpty(entity.Code))
                return;

            if (await _context.Languages.AnyAsync(x => x.Id != entity.Id && x.Code == entity.Code))
                throw new ClientException($"Language code '{entity.Code}' is already used by another language.");
        }

        protected override string DescribeEntity(Language entity) => $"Language '{entity.Name}'";

        protected override async Task<string?> DescribeUsageAsync(Language entity)
        {
            var movies = await _context.Movies.CountAsync(x => x.LanguageId == entity.Id);

            return UsageDescription.Describe((movies, "movie"));
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
