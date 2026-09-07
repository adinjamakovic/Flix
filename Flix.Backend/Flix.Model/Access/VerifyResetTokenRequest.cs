namespace Flix.Model.Access
{
    public class VerifyResetTokenRequest
    {
        public string Email { get; set; } = string.Empty;
        public string Token { get; set; } = string.Empty;
    }
}
