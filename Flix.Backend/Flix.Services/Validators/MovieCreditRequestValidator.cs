using Flix.Model.Requests;
using FluentValidation;

namespace Flix.Services.Validators
{
    // Shared by the insert and update validators - a credit row is the same shape
    // either way, and both movie requests carry a list of them.
    public class MovieCreditRequestValidator : AbstractValidator<MovieCreditRequest>
    {
        public MovieCreditRequestValidator()
        {
            RuleFor(x => x.CastMemberId)
                .GreaterThan(0);

            RuleFor(x => x.Role)
                .IsInEnum();

            RuleFor(x => x.CharacterName)
                .MaximumLength(100);

            RuleFor(x => x.OrderOfAppearence)
                .GreaterThanOrEqualTo(0);
        }
    }
}
