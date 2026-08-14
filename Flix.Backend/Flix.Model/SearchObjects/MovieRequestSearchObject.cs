using Flix.Model.Enums;

namespace Flix.Model.SearchObjects
{
    public class MovieRequestSearchObject : BaseSearchObject
    {
        public MovieRequestStatus? status {get; set;}
        public bool? IncludeUser {get; set;}
        public bool? IncludeMovie {get; set;}
    }
}