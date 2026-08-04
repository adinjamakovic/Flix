namespace Flix.Model.Responses
{
    public class UserResponse
    {
        public int Id { get; set; }
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string Username { get; set; } = string.Empty;
        public string Role { get; set; } = string.Empty;
        public bool IsActive { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? LastLoginAt { get; set; }
        public string? PhoneNumber { get; set; }
        public string? ProfileImageBase64 { get; set; }
        public string? Bio { get; set; }
        public int MoviesWatched { get; set; }
        public int ReviewsWritten { get; set; }
        public CountryResponse? Country {get; set;}
    }
}
