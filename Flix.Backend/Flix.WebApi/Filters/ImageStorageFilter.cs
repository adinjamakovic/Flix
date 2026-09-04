using Flix.CommonServices.ImageStorageService;
using Flix.Services.Database;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.EntityFrameworkCore;

namespace Flix.WebApi.Filters
{
    // Blob storage takes part in no transaction, so the ordering an image replacement needs is
    // enforced here for every write in the application at once: the upload happens first, the old
    // blob is only deleted once the new path has been saved, and an upload the request never
    // managed to save is deleted again on the way out.
    public class ImageStorageFilter : IAsyncActionFilter
    {
        private readonly IImageStorageService _imageStorageService;
        private readonly FlixDbContext _context;

        public ImageStorageFilter(IImageStorageService imageStorageService, FlixDbContext context)
        {
            _imageStorageService = imageStorageService;
            _context = context;
        }

        public async Task OnActionExecutionAsync(ActionExecutingContext context, ActionExecutionDelegate next)
        {
            void OnSavedChanges(object? sender, SavedChangesEventArgs e) => _imageStorageService.MarkPersisted();

            _context.SavedChanges += OnSavedChanges;

            try
            {
                var executed = await next();

                if (executed.Exception is null || executed.ExceptionHandled)
                    await _imageStorageService.CommitAsync();
                else
                    await _imageStorageService.RollbackAsync();
            }
            catch
            {
                await _imageStorageService.RollbackAsync();
                throw;
            }
            finally
            {
                _context.SavedChanges -= OnSavedChanges;
            }
        }
    }
}
