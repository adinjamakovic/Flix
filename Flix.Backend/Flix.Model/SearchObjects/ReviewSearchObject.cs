namespace Flix.Model.SearchObjects
{
    public class ReviewSearchObject : BaseSearchObject
    {
        public string? Username { get; set; }
        // Used to for a less strict search, "Alien" also returns 
        // reviews for the movie "Aliens"
        public string? MovieTitle { get; set;  }
        // Used for a more strict approach, only reviews
        // for the movie "Alien", wont return reviews for "Aliens"
        public int? MovieId {get; set;}
        public decimal? ReviewRating { get; set; }
        // Used to filter by certain user, for example: Get Reviews from User John Doe with ID 999
        public int? UserId { get; set; }
        // Used to filter reviews based on a certain users follower base, usually the logged in user
        public int? FollowedByUserId { get; set; }
        public bool? IncludeUser { get; set; }
        public bool? IncludeMovie { get; set; }
    }
}
