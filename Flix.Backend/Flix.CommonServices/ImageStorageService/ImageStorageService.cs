using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;
using Azure.Storage.Sas;
using Flix.Model.Exceptions;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;

namespace Flix.CommonServices.ImageStorageService
{
    public class ImageStorageService : IImageStorageService
    {
        private const string ContainerName = "uploads";

        // How long a URL handed to a client stays valid. Clients re-read the entity
        // (and so get a fresh URL) far more often than this.
        private static readonly TimeSpan ReadUrlLifetime = TimeSpan.FromHours(1);

        private readonly BlobServiceClient _blobServiceClient;
        private readonly ILogger<ImageStorageService> _logger;

        // Blob writes cannot join the database transaction, so an upload is held here until the
        // row carrying its path has been saved: until then the new blob is the one to drop on a
        // failure, and only afterwards does the path it replaced become safe to delete.
        private readonly List<PendingUpload> _pending = new();
        private readonly List<string> _superseded = new();

        private sealed record PendingUpload(string Path, string? ReplacedPath);

        public ImageStorageService(BlobServiceClient blobServiceClient, ILogger<ImageStorageService> logger)
        {
            _blobServiceClient = blobServiceClient;
            _logger = logger;
        }

        private static string GetCategoryFolder(ImageStorageCategory category) => category switch
        {
            ImageStorageCategory.CastMember => "CastMember",
            ImageStorageCategory.Clash => "Clash",
            ImageStorageCategory.Country => "Country",
            ImageStorageCategory.Movie => "Movie",
            ImageStorageCategory.Studio => "Studio",
            ImageStorageCategory.User => "User",
            _ => throw new ArgumentOutOfRangeException(nameof(category), category, "Unknown image storage category")
        };

        public async Task DeleteIfExistsAsync(ImageStorageCategory category, string? storedPath)
        {
            if (string.IsNullOrWhiteSpace(storedPath))
                return;

            var container = _blobServiceClient.GetBlobContainerClient(ContainerName);
            await container.GetBlobClient(storedPath).DeleteIfExistsAsync();
        }

        public async Task<string?> ReplaceIfUploadedAsync(ImageStorageCategory category, string? currentStoredPath, IFormFile? newImage)
        {
            if(newImage is null || newImage.Length == 0)
                return currentStoredPath;

            return await UploadAsync(category, newImage, currentStoredPath) ?? currentStoredPath;
        }

        public Task<string?> SaveAsync(ImageStorageCategory category, IFormFile? image)
            => UploadAsync(category, image, null);

        private async Task<string?> UploadAsync(ImageStorageCategory category, IFormFile? image, string? replacedPath)
        {
            if (image is null || image.Length == 0)
                return null;

            if (image.Length > ImageValidationRules.MaxImageSizeBytes)
                throw new ClientException(
                    $"Image must be {ImageValidationRules.MaxImageSizeBytes / (1024 * 1024)} MB or smaller.");

            var extension = Path.GetExtension(image.FileName);
            if( string.IsNullOrWhiteSpace(extension) || !ImageValidationRules.AllowedExtensions.Contains(extension))
                throw new ClientException(
                    $"Image must be one of the following types: {string.Join(", ", ImageValidationRules.AllowedExtensions)}.");

            if (!ImageValidationRules.HasAllowedContentType(image))
                throw new ClientException(
                    $"Image must be sent as one of the following content types, matching its extension: {string.Join(", ", ImageValidationRules.AllowedContentTypes)}.");

            if (!ImageValidationRules.HasMatchingSignature(image))
                throw new ClientException("Image contents do not match its file type.");

            var container = _blobServiceClient.GetBlobContainerClient(ContainerName);
            await container.CreateIfNotExistsAsync();

            var bloblName = $"{GetCategoryFolder(category)}/{Guid.NewGuid()}{extension}";
            var blobClient = container.GetBlobClient(bloblName);

            await blobClient.UploadAsync(image.OpenReadStream(), new BlobHttpHeaders { ContentType = image.ContentType });

            _pending.Add(new PendingUpload(
                bloblName,
                string.IsNullOrWhiteSpace(replacedPath) ? null : replacedPath));

            return bloblName;
        }

        public void MarkPersisted()
        {
            foreach (var upload in _pending)
            {
                if (upload.ReplacedPath is not null)
                    _superseded.Add(upload.ReplacedPath);
            }

            _pending.Clear();
        }

        public async Task CommitAsync()
        {
            MarkPersisted();

            var superseded = _superseded.ToList();
            _superseded.Clear();

            foreach (var path in superseded)
                await TryDeleteAsync(path);
        }

        public async Task RollbackAsync()
        {
            var orphans = _pending.Select(x => x.Path).ToList();

            // Superseded blobs are deliberately kept: the write that replaced them may itself
            // have been rolled back, and a leaked blob beats a row pointing at a deleted one.
            _pending.Clear();
            _superseded.Clear();

            foreach (var path in orphans)
                await TryDeleteAsync(path);
        }

        private async Task TryDeleteAsync(string path)
        {
            try
            {
                var container = _blobServiceClient.GetBlobContainerClient(ContainerName);
                await container.GetBlobClient(path).DeleteIfExistsAsync();
            }
            catch (Exception ex)
            {
                // Cleanup runs after the caller's work is done, so a failure here must not
                // turn a completed request into an error - the blob is only left behind.
                _logger.LogError(ex, "Failed to delete blob {Path}", path);
            }
        }

        public string? ToPublicPath(ImageStorageCategory category, string? storedPath)
        {
            if (string.IsNullOrWhiteSpace(storedPath))
                return null;

            var container = _blobServiceClient.GetBlobContainerClient(ContainerName);
            var blob = container.GetBlobClient(storedPath);

            // The container is created without public access, so a bare blob URI would come
            // back 404 for the client. A short-lived read-only SAS hands out the one blob
            // instead of opening every upload to anonymous reads.
            if (!blob.CanGenerateSasUri)
                return blob.Uri.ToString();

            return blob
                .GenerateSasUri(BlobSasPermissions.Read, DateTimeOffset.UtcNow.Add(ReadUrlLifetime))
                .ToString();
        }
    }
}
