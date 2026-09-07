using Flix.Model.Exceptions;
using Flix.Services.Interfaces;
using Flix.WebApi.Extensions;
using System.Security.Claims;

namespace Flix.WebApi.Services.CurrentUser
{
    public class CurrentUserService : ICurrentUserService
    {
        private readonly IHttpContextAccessor _httpContextAccessor;

        public CurrentUserService(IHttpContextAccessor httpContextAccessor)
        {
            _httpContextAccessor = httpContextAccessor;
        }

        private ClaimsPrincipal? Principal => _httpContextAccessor.HttpContext?.User;

        public int? UserId => Principal.GetUserId();

        public string? Username => Principal.GetUsername();

        public string? Role => Principal.GetRole();

        public bool IsAuthenticated => Principal.IsAuthenticated();

        public bool IsAdmin => string.Equals(Role, "Admin", StringComparison.OrdinalIgnoreCase);

        public int GetUserId() =>
            UserId ?? throw new ClientException("No authenticated user on the current request.");
    }
}
