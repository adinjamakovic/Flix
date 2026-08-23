using Flix.Model.Requests;
using FluentValidation;

namespace Flix.Services.Validators
{
    public class UserReportInsertRequestValidator : AbstractValidator<UserReportInsertRequest>
    {
        public UserReportInsertRequestValidator()
        {
            RuleFor(x => x.ReportedUserId)
                .GreaterThan(0)
                .WithMessage("A valid User must be sent");

            RuleFor(x => x.Header)
                .NotEmpty()
                .MaximumLength(150);

            RuleFor(x => x.Description)
                .MaximumLength(2000)
                .When(x => !string.IsNullOrWhiteSpace(x.Description));
        }
    }
}
