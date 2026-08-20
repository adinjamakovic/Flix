namespace Flix.Model.Responses
{
    public class ReviewResponse
    {
        public int Id { get; set; }
        public UserResponse? User { get; set; }
        public MovieResponse? Movie { get; set; }
        public decimal? Rating { get; set; }
        public bool? IsLiked { get; set; }
        public string? Content { get; set; }
        public bool? ContainsSpoilers { get; set; }
        public bool? IsDiaryEntry { get; set; }
        public bool? IsRewatch { get; set; }
        public DateTime? WatchedOn { get; set; }
        public DateTime? CreatedAt { get; set; }
    }
}
