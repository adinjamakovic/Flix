using Flix.CommonServices.ImageStorageService;
using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Database;
using Flix.Model.Enums;
using Flix.Model.Exceptions;
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
        private readonly IImageStorageService _imageStorageService;
        private readonly IResponseImageUrlResolver _imageUrlResolver;

        public ClashService(
            FlixDbContext context,
            IMapper mapper,
            IValidator<ClashInsertRequest> insertValidator,
            IValidator<ClashUpdateRequest> updateValidator,
            IImageStorageService imageStorageService,
            IResponseImageUrlResolver imageUrlResolver)
            : base(context, mapper, insertValidator, updateValidator)
        {
            _imageStorageService = imageStorageService;
            _imageUrlResolver = imageUrlResolver;
        }

        protected override async Task BeforeInsertAsync(Clash entity, ClashInsertRequest request)
        {
            entity.BannerImage = await _imageStorageService.SaveAsync(ImageStorageCategory.Clash, request.BannerImage);
        }

        protected override async Task BeforeUpdateAsync(Clash entity, ClashUpdateRequest request)
        {
            if (request.BannerImage is null)
                return;

            entity.BannerImage = await _imageStorageService.ReplaceIfUploadedAsync(
                ImageStorageCategory.Clash,
                entity.BannerImage,
                request.BannerImage);
        }

        protected override Task BeforeDeleteAsync(Clash entity)
        {
            if (entity.Status == ClashStatus.Completed)
                throw new ClientException("Completed clashes cannot be deleted.");

            return Task.CompletedTask;
        }

        protected override async Task AfterDeleteAsync(Clash entity)
        {
            await _imageStorageService.DeleteIfExistsAsync(ImageStorageCategory.Clash, entity.BannerImage);
        }

        protected override ClashResponse MapToResponse(Clash entity)
        {
            var response = base.MapToResponse(entity);

            _imageUrlResolver.Resolve(response);

            return response;
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
