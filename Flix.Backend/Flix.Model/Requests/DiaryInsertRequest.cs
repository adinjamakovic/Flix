namespace Flix.Model.Requests
{
    public class DiaryInsertRequest
    {
        public int MovieId { get; set; }
        public decimal? Rating { get; set; }
        public bool IsLiked { get; set; }
        public string? Content { get; set; }
        public bool ContainsSpoilers { get; set; }
        public bool IsRewatch { get; set; }
    }
}
