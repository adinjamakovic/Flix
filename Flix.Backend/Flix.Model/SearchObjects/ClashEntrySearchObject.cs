namespace Flix.Model.SearchObjects
{
    public class ClashEntrySearchObject : BaseSearchObject
    {
        public int? ClashId { get; set; }
        public string? Username { get; set; }
        public bool? IncludeUser { get; set; }
        public bool? IncludeMovieList { get; set; }
    }
}
