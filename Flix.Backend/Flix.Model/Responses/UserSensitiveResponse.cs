namespace Flix.Model.Responses
{
    // Login only. This one never leaves the API - AccessManager verifies the password against it.
    public class UserSensitiveResponse : UserAdminResponse
    {
        public string PasswordHash { get; set; } = string.Empty;
        public string PasswordSalt { get; set; } = string.Empty;
    }
}
