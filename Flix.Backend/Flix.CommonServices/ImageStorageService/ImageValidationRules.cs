using Microsoft.AspNetCore.Http;
using FluentValidation;

namespace Flix.CommonServices.ImageStorageService
{
    public static class ImageValidationRules
    {
        public const long MaxImageSizeBytes = 5 * 1024 * 1024; // 5 MB

        public static readonly IReadOnlySet<string> AllowedExtensions = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        {
            ".jpg",
            ".jpeg",
            ".png",
            ".gif",
            ".webp"
        };

        public static IRuleBuilderOptions<T, IFormFile?> ValidImage<T>(this IRuleBuilder<T, IFormFile?> rule) =>
        rule
            .Must(HasAllowedExtension)
                .WithMessage($"Image must be one of the following types: {string.Join(", ", AllowedExtensions)}.")
            .Must(file => file is null || file.Length <= MaxImageSizeBytes)
                .WithMessage($"Image must be {MaxImageSizeBytes / (1024 * 1024)} MB or smaller.");

        private static bool HasAllowedExtension(IFormFile? file)
        {
            if (file is null || file.Length == 0)
                return true;

            var extension = Path.GetExtension(file.FileName);
            return !string.IsNullOrWhiteSpace(extension) && AllowedExtensions.Contains(extension);
        }
    }
}
