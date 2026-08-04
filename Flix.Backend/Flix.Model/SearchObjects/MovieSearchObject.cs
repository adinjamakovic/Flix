using System.Collections.Generic;
using System.Text;

namespace Flix.Model.SearchObjects
{
    public class MovieSearchObject : BaseSearchObject
    {
        public string? Title { get; set; }
        public int? CountryId { get; set; }
        public string? DirectorName { get; set; }
        public int? LanguageId { get; set; }
        public int? GenreId { get; set; }
        public bool? IsEnabled { get; set; }
        public DateTime? ReleasedAfter { get; set; }
        public DateTime? ReleasedBefore { get; set; }
        public bool? IncludeCast { get; set; }
        public bool? IncludeReviews { get; set; }
    }
}
