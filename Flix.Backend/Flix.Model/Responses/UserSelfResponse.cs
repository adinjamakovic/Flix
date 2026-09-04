namespace Flix.Model.Responses
{
    public class UserSelfResponse : UserResponse
    {
        public string Email { get; set; } = string.Empty;
        public string? PhoneNumber { get; set; }
    }
}
