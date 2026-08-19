namespace Flix.Model.Responses
{
    public class ReviewCountResponse
    {
        // Whichever of the two the count was asked for; the other stays null.
        public int? UserId { get; set; }
        public int? MovieId { get; set; }
        public int TotalCount { get; set; }
        public int UnratedCount { get; set; }
        public decimal? AverageRating { get; set; }
        public List<ReviewRatingCountResponse> Ratings { get; set; } = [];
    }

    public class ReviewRatingCountResponse
    {
        public decimal Rating { get; set; }
        public int Count { get; set; }
    }
}
