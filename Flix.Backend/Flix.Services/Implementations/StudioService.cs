using Flix.CommonServices.ImageStorageService;
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
    public class StudioService :
        BaseCRUDService<
            Studio,
            StudioResponse,
            StudioSearchObject,
            StudioInsertRequest,
            StudioUpdateRequest>,
        IStudioService
    {
        private readonly IImageStorageService _imageStorageService;

        public StudioService(
            FlixDbContext context,
            IMapper mapper,
            IValidator<StudioInsertRequest> insertValidator,
            IValidator<StudioUpdateRequest> updateValidator,
            IImageStorageService imageStorageService
            ) : base(context, mapper, insertValidator, updateValidator)
        {
            _imageStorageService = imageStorageService;
        }

        protected override async Task BeforeInsertAsync(Studio entity, StudioInsertRequest request)
        {
            entity.Logo = await _imageStorageService.SaveAsync(ImageStorageCategory.Studio, request.Logo);
        }

        protected override async Task BeforeUpdateAsync(Studio entity, StudioUpdateRequest request)
        {
            if (request.Logo is null)
                return;

            entity.Logo = await _imageStorageService.ReplaceIfUploadedAsync(
                ImageStorageCategory.Studio,
                entity.Logo,
                request.Logo);
        }

        protected override async Task AfterDeleteAsync(Studio entity)
        {
            await _imageStorageService.DeleteIfExistsAsync(ImageStorageCategory.Studio, entity.Logo);
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
