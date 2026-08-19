using Flix.Model.Requests;
using FluentValidation;

namespace Flix.Services.Validators
{
    public class DiaryInsertRequestValidator : AbstractValidator<DiaryInsertRequest>
    {
        public DiaryInsertRequestValidator()
        {
            RuleFor(x => x.MovieId)
                .GreaterThan(0);

            // Review.Rating is decimal(2,1) ranged 0.5 - 5.0, and the app only ever offers half stars
            RuleFor(x => x.Rating)
                .InclusiveBetween(0.5m, 5.0m)
                .Must(rating => rating % 0.5m == 0)
                .WithMessage("A rating has to be given in half stars.")
                .When(x => x.Rating.HasValue);

            RuleFor(x => x.ContainsSpoilers)
                .Equal(false)
                .When(x => string.IsNullOrWhiteSpace(x.Content))
                .WithMessage("An entry without a written review cannot contain spoilers.");
        }
    }
}
