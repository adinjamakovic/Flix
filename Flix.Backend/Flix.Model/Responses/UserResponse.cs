namespace Flix.Model.Responses
{
    public class UserResponse
    {
        public int Id { get; set; }
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string Username { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
        public string? ProfileImage { get; set; }
        public string? Bio { get; set; }
        public int MoviesWatched { get; set; }
        public int ReviewsWritten { get; set; }
        public int FollowerCount { get; set; }
        public int FollowingCount { get; set; }
        public CountryResponse? Country {get; set;}
        public List<ReviewResponse>? Reviews {get; set;}
    }
}
