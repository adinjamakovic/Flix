using System;

namespace Flix.Model.Responses
{
    public class UserSensitiveResponse : UserResponse
    {
        public string PasswordHash { get; set; } = string.Empty;
        public string PasswordSalt { get; set; } = string.Empty;
    }
}
