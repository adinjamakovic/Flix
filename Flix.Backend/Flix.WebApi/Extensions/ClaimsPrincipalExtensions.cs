using Flix.WebApi.Services.AccessManager;
using System.Security.Claims;

namespace Flix.WebApi.Extensions
{
    public static class ClaimsPrincipalExtensions
    {
        // AccessManager writes the custom claim names in ClaimNames, but a token that went through
        // JWT inbound claim mapping (or any standards-compliant issuer) can carry the same values
        // under the well-known types instead, so every lookup falls back to those.
        public static int? GetUserId(this ClaimsPrincipal? principal)
        {
            var raw = principal.FindFirstValue(ClaimNames.Id, ClaimTypes.NameIdentifier, "nameid", "sub");

            return int.TryParse(raw, out var id) ? id : null;
        }

        public static string? GetUsername(this ClaimsPrincipal? principal) =>
            principal.FindFirstValue(ClaimNames.Username, ClaimTypes.Name, "unique_name");

        public static string? GetRole(this ClaimsPrincipal? principal) =>
            principal.FindFirstValue(ClaimNames.Role, ClaimTypes.Role, "role");

        public static bool IsAuthenticated(this ClaimsPrincipal? principal) =>
            principal?.Identity?.IsAuthenticated == true;

        private static string? FindFirstValue(this ClaimsPrincipal? principal, params string[] claimTypes)
        {
            if (principal is null)
                return null;

            foreach (var claimType in claimTypes)
            {
                var value = principal.FindFirst(claimType)?.Value;
                if (!string.IsNullOrWhiteSpace(value))
                    return value;
            }

            return null;
        }
    }
}
