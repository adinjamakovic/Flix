using Flix.Model.Access;

namespace Flix.Services.Interfaces
{
    public interface IPasswordResetService
    {
        Task RequestResetAsync(ForgotPasswordRequest request);
        Task VerifyTokenAsync(VerifyResetTokenRequest request);
        Task ResetPasswordAsync(ResetPasswordRequest request);
    }
}
