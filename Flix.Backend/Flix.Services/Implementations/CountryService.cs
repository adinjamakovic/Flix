using Flix.CommonServices.ImageStorageService;
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
    public class CountryService :
        BaseCRUDService<
            Country,
            CountryResponse,
            CountrySearchObject,
            CountryInsertRequest,
            CountryUpdateRequest>,
        ICountryService
    {
        private readonly IImageStorageService _imageStorageService;
        private readonly IResponseImageUrlResolver _imageUrlResolver;

        public CountryService(
            FlixDbContext context,
            IMapper mapper,
            IValidator<CountryInsertRequest> insertValidator,
            IValidator<CountryUpdateRequest> updateValidator,
            IImageStorageService imageStorageService,
            IResponseImageUrlResolver imageUrlResolver
            ) : base(context, mapper, insertValidator, updateValidator)
        {
            _imageStorageService = imageStorageService;
            _imageUrlResolver = imageUrlResolver;
        }

        protected override async Task BeforeInsertAsync(Country entity, CountryInsertRequest request)
        {
            entity.FlagImage = await _imageStorageService.SaveAsync(ImageStorageCategory.Country, request.FlagImage);
        }

        protected override async Task BeforeUpdateAsync(Country entity, CountryUpdateRequest request)
        {
            if (request.FlagImage is null)
                return;

            entity.FlagImage = await _imageStorageService.ReplaceIfUploadedAsync(
                ImageStorageCategory.Country,
                entity.FlagImage,
                request.FlagImage);
        }

        protected override async Task AfterDeleteAsync(Country entity)
        {
            await _imageStorageService.DeleteIfExistsAsync(ImageStorageCategory.Country, entity.FlagImage);
        }

        protected override CountryResponse MapToResponse(Country entity)
        {
            var response = base.MapToResponse(entity);

            _imageUrlResolver.Resolve(response);

            return response;
        }

        protected override string DescribeEntity(Country entity) => $"Country '{entity.Name}'";

        protected override async Task<string?> DescribeUsageAsync(Country entity)
        {
            var movies = await _context.Movies.CountAsync(x => x.CountryId == entity.Id);
            var users = await _context.Users.CountAsync(x => x.CountryId == entity.Id);
            var castMembers = await _context.CastMembers.CountAsync(x => x.CountryId == entity.Id);

            return UsageDescription.Describe(
                (movies, "movie"),
                (users, "user"),
                (castMembers, "cast member"));
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
