using Microsoft.AspNetCore.Http;

namespace Flix.Model.Requests
{
    public class UserUpdateRequest
    {
        public string? FirstName { get; set; } = string.Empty;
        public string? LastName { get; set; } = string.Empty;
        public string? Email { get; set; } = string.Empty;
        public string? Username { get; set; } = string.Empty;
        public string? Password { get; set; } = string.Empty;
        public string? PhoneNumber { get; set; }
        public string? Bio { get; set; }
        public int? CountryId { get; set; }
        public int? RoleId { get; set; }
        public IFormFile? ProfileImage { get; set; }
    }
}
