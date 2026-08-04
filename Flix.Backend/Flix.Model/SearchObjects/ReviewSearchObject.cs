namespace Flix.Model.SearchObjects
{
    public class ReviewSearchObject : BaseSearchObject
    {
        public string? Username { get; set; }
        public string? MovieTitle { get; set;  }
        public decimal? ReviewRating { get; set; }
        public bool? IncludeUser { get; set; }
        public bool? IncludeMovie { get; set; }
    }
}
