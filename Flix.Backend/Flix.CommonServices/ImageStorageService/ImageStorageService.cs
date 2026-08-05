using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;
using Azure.Storage.Sas;
using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Text;

namespace Flix.CommonServices.ImageStorageService
{
    public class ImageStorageService : IImageStorageService
    {
        private const string ContainerName = "uploads";

        // How long a URL handed to a client stays valid. Clients re-read the entity
        // (and so get a fresh URL) far more often than this.
        private static readonly TimeSpan ReadUrlLifetime = TimeSpan.FromHours(1);

        private readonly BlobServiceClient _blobServiceClient;
        
        public ImageStorageService(BlobServiceClient blobServiceClient)
        {
            _blobServiceClient = blobServiceClient;
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

            await DeleteIfExistsAsync(category, currentStoredPath);
            return await SaveAsync(category, newImage);
        }

        public async Task<string?> SaveAsync(ImageStorageCategory category, IFormFile? image)
        {
            if (image is null || image.Length == 0)
                return null;

            var extension = Path.GetExtension(image.FileName);
            if( string.IsNullOrWhiteSpace(extension) || !ImageValidationRules.AllowedExtensions.Contains(extension))
                throw new Exception("Invalid image extension");

            var container = _blobServiceClient.GetBlobContainerClient(ContainerName);
            await container.CreateIfNotExistsAsync();

            var bloblName = $"{GetCategoryFolder(category)}/{Guid.NewGuid()}{extension}";
            var blobClient = container.GetBlobClient(bloblName);

            await blobClient.UploadAsync(image.OpenReadStream(), new BlobHttpHeaders { ContentType = image.ContentType });

            return bloblName;   
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
