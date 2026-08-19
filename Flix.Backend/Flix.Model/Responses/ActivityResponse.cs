using Flix.Model.Enums;

namespace Flix.Model.Responses
{
    public class ActivityResponse
    {
        public required int Id {get; set;}
        public required UserResponse User {get; set;}
        public ActivityType Type {get; set;}
        public MovieResponse? Movie {get; set;}
        public ReviewResponse? Review {get; set;}
        public ClashResponse? Clash {get; set;}
        public MovieListResponse? MovieList {get; set;}
        public UserResponse? TargetUser {get; set;}
        public DateTime CreatedAt {get; set;}
    }
}