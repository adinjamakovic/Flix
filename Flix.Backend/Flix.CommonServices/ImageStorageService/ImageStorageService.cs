using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;
using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Text;

namespace Flix.CommonServices.ImageStorageService
{
    public class ImageStorageService : IImageStorageService
    {
        private const string ContainerName = "uploads";
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
                return string.Empty;

            var container = _blobServiceClient.GetBlobContainerClient(ContainerName);
            return container.GetBlobClient(storedPath).Uri.ToString();
        }
    }
}
