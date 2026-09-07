using Flix.CommonServices.ImageStorageService;
using Flix.Model.Requests;
using FluentValidation;

namespace Flix.Services.Validators
{
    public class CountryUpdateRequestValidator : AbstractValidator<CountryUpdateRequest>
    {
        public CountryUpdateRequestValidator()
        {
            RuleFor(x => x.Name)
                .MaximumLength(100);

            RuleFor(x => x.Code)
                .MaximumLength(5);

            RuleFor(x => x.FlagImage)
                .ValidImage();
        }
    }
}
