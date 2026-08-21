using Flix.Model.Enums;
using Flix.Model.Requests;
using FluentValidation;

namespace Flix.Services.Validators
{
    public class MovieIssueReportUpdateRequestValidator : AbstractValidator<MovieIssueReportUpdateRequest>
    {
        public MovieIssueReportUpdateRequestValidator()
        {
            RuleFor(x => x.MovieId)
                .GreaterThan(0)
                .WithMessage("A valid Movie must be sent");

            RuleFor(x => x.Header)
                .NotEmpty()
                .MaximumLength(150);

            RuleFor(x => x.Description)
                .MaximumLength(2000)
                .When(x => !string.IsNullOrWhiteSpace(x.Description));

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
