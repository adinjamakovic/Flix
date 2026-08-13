namespace Flix.Services.Interfaces
{
    public interface ICurrentUserService
    {
        int? UserId { get; }
        string? Username { get; }
        string? Role { get; }
        bool IsAuthenticated { get; }
        bool IsAdmin { get; }
        int GetUserId();
    }
}
