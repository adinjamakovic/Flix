using Flix.CommonServices.ImageStorageService;
using Flix.Model.Requests;
using FluentValidation;

namespace Flix.Services.Validators
{
    public class CastMemberUpdateRequestValidator : AbstractValidator<CastMemberUpdateRequest>
    {
        public CastMemberUpdateRequestValidator()
        {
            RuleFor(x => x.FirstName)
                .MaximumLength(100);

            RuleFor(x => x.LastName)
                .MaximumLength(100);

            RuleFor(x => x.Photo)
                .ValidImage();
        }
    }
}
