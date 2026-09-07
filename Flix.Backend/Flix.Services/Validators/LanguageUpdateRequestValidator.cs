using Flix.Model.Requests;
using FluentValidation;

namespace Flix.Services.Validators
{
    public class LanguageUpdateRequestValidator : AbstractValidator<LanguageUpdateRequest>
    {
        public LanguageUpdateRequestValidator()
        {
            RuleFor(x => x.Name)
                .MaximumLength(60);

            RuleFor(x => x.Code)
                .MaximumLength(5);
        }
    }
}
