using Flix.CommonServices.ImageStorageService;
using Flix.Model.Requests;
using FluentValidation;

namespace Flix.Services.Validators
{
    public class UserUpdateRequestValidator : AbstractValidator<UserUpdateRequest>
    {
        public UserUpdateRequestValidator()
        {
            RuleFor(x => x.FirstName)
                .MaximumLength(50);

            RuleFor(x => x.LastName)
                .MaximumLength(50);

            RuleFor(x => x.Email)
                .EmailAddress()
                .MaximumLength(150);

            RuleFor(x => x.Username)
                .MaximumLength(100);

            // An update may leave the password out entirely, in which case the current one
            // is kept. It is only held to the insert rules when one is actually supplied.
            RuleFor(x => x.Password)
            .MinimumLength(8)
            .WithMessage("Password must be at least 8 characters.")
            .Matches("(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[^A-Za-z0-9])")
            .WithMessage("Password must contain upper, lower, a digit, and a special character.")
            .When(x => !string.IsNullOrEmpty(x.Password));

            RuleFor(x => x.PhoneNumber)
                .MaximumLength(25);

            RuleFor(x => x.Bio)
                .MaximumLength(500);

            RuleFor(x => x.RoleId)
                .GreaterThan(0)
                .When(x => x.RoleId.HasValue);

            RuleFor(x => x.ProfileImage)
                .ValidImage();
        }
    }
}
