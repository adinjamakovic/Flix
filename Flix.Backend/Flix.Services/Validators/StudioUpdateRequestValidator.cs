using Flix.CommonServices.ImageStorageService;
using Flix.Model.Requests;
using FluentValidation;

namespace Flix.Services.Validators
{
    public class StudioUpdateRequestValidator : AbstractValidator<StudioUpdateRequest>
    {
        public StudioUpdateRequestValidator()
        {
            RuleFor(x => x.Name)
                .NotEmpty()
                .MaximumLength(100);

            RuleFor(x => x.Logo)
                .ValidImage();
        }
    }
}
