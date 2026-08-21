using Flix.Model.Requests;
using FluentValidation;

namespace Flix.Services.Validators
{
    public class MovieIssueReportInsertRequestValidator : AbstractValidator<MovieIssueReportInsertRequest>
    {
        public MovieIssueReportInsertRequestValidator()
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
        }
    }
}
