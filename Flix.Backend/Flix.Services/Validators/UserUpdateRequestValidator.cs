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

            RuleFor(x => x.Password)
            .MinimumLength(8)
            .WithMessage("Password must be at least 8 characters.")
            .Matches("(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[^A-Za-z0-9])")
            .WithMessage("Password must contain upper, lower, a digit, and a special character.");

            RuleFor(x => x.PhoneNumber)
                .MaximumLength(25);

            RuleFor(x => x.Bio)
                .MaximumLength(500);
        }
    }
}
