using Flix.Model.Enums;

namespace Flix.Model.SearchObjects
{
    public class ActivitySearchObject : BaseSearchObject
    {
        public int? UserId {get; set;}
        public ActivityType? ActivityType {get; set;}
        public int? MovieId {get; set;}
        public int? ClashId {get; set;}
        public int? TargetUserId {get; set;}
    }
}