using Microsoft.AspNetCore.Http;
using FluentValidation;

namespace Flix.CommonServices.ImageStorageService
{
    public static class ImageValidationRules
    {
        public const long MaxImageSizeBytes = 5 * 1024 * 1024; // 5 MB

        private const int SignatureLength = 12;

        private static readonly byte[] JpegSignature = [0xFF, 0xD8, 0xFF];
        private static readonly byte[] PngSignature = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];

        private static readonly IReadOnlyDictionary<string, string> ContentTypeByExtension = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
        {
            [".jpg"] = "image/jpeg",
            [".jpeg"] = "image/jpeg",
            [".png"] = "image/png",
            [".gif"] = "image/gif",
            [".webp"] = "image/webp"
        };

        public static readonly IReadOnlySet<string> AllowedExtensions =
            ContentTypeByExtension.Keys.ToHashSet(StringComparer.OrdinalIgnoreCase);

        public static readonly IReadOnlySet<string> AllowedContentTypes =
            ContentTypeByExtension.Values.ToHashSet(StringComparer.OrdinalIgnoreCase);

        public static IRuleBuilderOptions<T, IFormFile?> ValidImage<T>(this IRuleBuilder<T, IFormFile?> rule) =>
        rule
            .Must(HasAllowedExtension)
                .WithMessage($"Image must be one of the following types: {string.Join(", ", AllowedExtensions)}.")
            .Must(HasAllowedContentType)
                .WithMessage($"Image must be sent as one of the following content types, matching its extension: {string.Join(", ", AllowedContentTypes)}.")
            .Must(HasMatchingSignature)
                .WithMessage("Image contents do not match its file type.")
            .Must(file => file is null || file.Length <= MaxImageSizeBytes)
                .WithMessage($"Image must be {MaxImageSizeBytes / (1024 * 1024)} MB or smaller.");

        public static bool HasAllowedExtension(IFormFile? file)
        {
            if (file is null || file.Length == 0)
                return true;

            return ExpectedContentType(file) is not null;
        }

        public static bool HasAllowedContentType(IFormFile? file)
        {
            if (file is null || file.Length == 0)
                return true;

            var expected = ExpectedContentType(file);
            if (expected is null)
                return true;

            var declared = file.ContentType?.Split(';')[0].Trim();
            return string.Equals(declared, expected, StringComparison.OrdinalIgnoreCase);
        }

        public static bool HasMatchingSignature(IFormFile? file)
        {
            if (file is null || file.Length == 0)
                return true;

            var expected = ExpectedContentType(file);
            if (expected is null)
                return true;

            Span<byte> header = stackalloc byte[SignatureLength];
            using var stream = file.OpenReadStream();
            var read = stream.ReadAtLeast(header, header.Length, throwOnEndOfStream: false);

            return MatchesSignature(expected, header[..read]);
        }

        private static string? ExpectedContentType(IFormFile file)
        {
            var extension = Path.GetExtension(file.FileName);
            if (string.IsNullOrWhiteSpace(extension))
                return null;

            return ContentTypeByExtension.TryGetValue(extension, out var contentType) ? contentType : null;
        }

        private static bool MatchesSignature(string contentType, ReadOnlySpan<byte> header) => contentType switch
        {
            "image/jpeg" => header.StartsWith(JpegSignature),
            "image/png" => header.StartsWith(PngSignature),
            "image/gif" => header.StartsWith("GIF87a"u8) || header.StartsWith("GIF89a"u8),
            "image/webp" => header.Length >= 12 && header.StartsWith("RIFF"u8) && header[8..12].SequenceEqual("WEBP"u8),
            _ => false
        };
    }
}
