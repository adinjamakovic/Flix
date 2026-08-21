namespace Flix.Model.Responses
{
    public class MovieUserStateResponse
    {
        public int MovieId { get; set; }
        public bool IsWatched { get; set; }
        public bool IsLiked { get; set; }
        public decimal? Rating { get; set; }
        public bool IsInWatchlist { get; set; }
        public int DiaryEntryCount { get; set; }
    }
}
