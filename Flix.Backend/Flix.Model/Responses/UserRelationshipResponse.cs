namespace Flix.Model.Responses
{
    public class UserRelationshipResponse
    {
        public int UserId { get; set; }
        public bool IsSelf { get; set; }
        public bool IsFollowing { get; set; }
        public bool IsFollowedBy { get; set; }
        public bool IsBlocked { get; set; }
        public bool IsBlockedBy { get; set; }
    }
}
