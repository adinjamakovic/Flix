using Flix.Model.Enums;
using Flix.Model.Requests;
using FluentValidation;

namespace Flix.Services.Validators
{
    public class UserReportUpdateRequestValidator : AbstractValidator<UserReportUpdateRequest>
    {
        public UserReportUpdateRequestValidator()
        {
            RuleFor(x => x.Status)
                .Must(status => status is ReportStatus.Resolved or ReportStatus.Dismissed)
                .When(x => x.Status.HasValue)
                .WithMessage("A report can only be resolved or dismissed");

            RuleFor(x => x.AdminComment)
                .MaximumLength(2000)
                .When(x => !string.IsNullOrWhiteSpace(x.AdminComment));
        }
    }
}
