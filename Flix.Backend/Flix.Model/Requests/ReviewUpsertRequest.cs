namespace Flix.Model.Requests
{
    public class ReviewUpsertRequest
    {
        public int MovieId { get; set; }
        public bool IsWatched { get; set; }
        public bool IsLiked { get; set; }
        public decimal? Rating { get; set; }
    }
}
