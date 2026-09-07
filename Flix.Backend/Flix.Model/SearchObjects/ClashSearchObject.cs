namespace Flix.Model.SearchObjects
{
    public class ClashSearchObject : BaseSearchObject
    {
        public string? Name { get; set; }
        public int? Status { get; set; }
        public bool? IncludeEntries { get; set; }
        public bool? IncludeLists { get; set; }
    }
}
