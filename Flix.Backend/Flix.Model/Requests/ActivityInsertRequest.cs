using Flix.Model.Enums;

namespace Flix.Model.Requests
{
    public class ActivityInsertRequest
    {
        public ActivityType Type {get; set;}
        public int? MovieId {get; set;}
        public int? ReviewId {get; set;}
        public int? ClashId {get; set;}
        public int? MovieListId {get; set;}
        public int? TargetUserId {get; set;}
    }
}