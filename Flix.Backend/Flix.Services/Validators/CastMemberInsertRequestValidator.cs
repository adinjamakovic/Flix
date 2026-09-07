using Flix.CommonServices.ImageStorageService;
using Flix.Model.Requests;
using FluentValidation;

namespace Flix.Services.Validators
{
    public class CastMemberInsertRequestValidator : AbstractValidator<CastMemberInsertRequest>
    {
        public CastMemberInsertRequestValidator()
        {
            RuleFor(x => x.FirstName)
                .MaximumLength(100)
                .NotEmpty();

            RuleFor(x => x.LastName)
                .MaximumLength(100)
                .NotEmpty();

            RuleFor(x => x.CountryId)
                .NotEmpty();

            RuleFor(x => x.Photo)
                .ValidImage();
        }
    }
}
