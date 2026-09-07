namespace Flix.Model.Messages
{
    public class PasswordResetRequested
    {
        public int Id { get; set; }
        public PasswordResetData? Data { get; set; }
    }
    public class PasswordResetData
    {
        public int UserId { get; set; }
        public string Token { get; set; } = string.Empty;
        public DateTime ExpiresAt { get; set; }
    }
}
