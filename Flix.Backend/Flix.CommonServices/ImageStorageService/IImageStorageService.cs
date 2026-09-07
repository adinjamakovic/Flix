using Microsoft.AspNetCore.Http;

namespace Flix.CommonServices.ImageStorageService
{
    // Interface that needs to be implemented if a service is to be used for storing images in the application.
    public interface IImageStorageService
    {
        Task<string?> SaveAsync(ImageStorageCategory category, IFormFile? image);
        Task DeleteIfExistsAsync(ImageStorageCategory category, string? storedPath);
        Task<string?> ReplaceIfUploadedAsync(
            ImageStorageCategory category,
            string? currentStoredPath,
            IFormFile? newImage
        );
        string? ToPublicPath(ImageStorageCategory category, string? storedPath);

        // The three below are driven centrally by ImageStorageFilter, not by the services doing
        // the uploading: an upload only supersedes what it replaces once the new path has been
        // written, and one that never got written is dropped again.
        void MarkPersisted();
        Task CommitAsync();
        Task RollbackAsync();
    }
}
