using Flix.CommonServices.ImageStorageService;
using Flix.Model.Requests;
using FluentValidation;
using System.Collections.Generic;
using System.Text;

namespace Flix.Services.Validators
{
    public class StudioInsertRequestValidator : AbstractValidator<StudioInsertRequest>
    {
        public StudioInsertRequestValidator()
        {
            RuleFor(x => x.Name)
                .NotEmpty()
                .MaximumLength(100);

            RuleFor(x => x.Logo)
                .ValidImage();
        }
    }
}
