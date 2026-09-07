namespace Flix.Model.Responses
{
    public class UserAdminResponse : UserSelfResponse
    {
        public string Role { get; set; } = string.Empty;
        public int? RoleId { get; set; }
        public bool IsActive { get; set; }
        public DateTime? LastLoginAt { get; set; }
    }
}
