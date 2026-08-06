namespace Flix.Model.Responses
{
    public class ClashEntryResponse
    {
        public int Id { get; set; }
        public int ClashId { get; set; }
        public UserResponse? User { get; set; }
        public MovieListResponse? MovieList { get; set; }
        public int Votes { get; set; }
        public bool IsWinner { get; set; }
        public DateTime? CreatedAt { get; set; }
    }
}
