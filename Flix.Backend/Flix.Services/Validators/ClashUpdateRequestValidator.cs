using Flix.CommonServices.ImageStorageService;
using Flix.Model.Requests;
using FluentValidation;
using System.Collections.Generic;
using System.Text;

namespace Flix.Services.Validators
{
    public class ClashUpdateRequestValidator : AbstractValidator<ClashUpdateRequest>
    {
        public ClashUpdateRequestValidator() {
            RuleFor(x => x.Name)
                .MaximumLength(150);

            RuleFor(x => x.Description)
                .MaximumLength(500);

            RuleFor(x => x.StartDate)
                .NotEmpty()
                .LessThan(x => x.EndDate)
                .WithMessage("Start date must be before end date.");

            RuleFor(x => x.EndDate)
                .NotEmpty()
                .GreaterThan(x => x.StartDate)
                .WithMessage("End date must be after start date.")
                .GreaterThanOrEqualTo(DateTime.UtcNow.Date)
                .WithMessage("End date cannot be in the past.");

            RuleFor(x => x.BannerImage)
                .ValidImage();
        }
    }
}
