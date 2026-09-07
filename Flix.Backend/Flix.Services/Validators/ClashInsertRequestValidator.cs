using Flix.CommonServices.ImageStorageService;
using Flix.Model.Requests;
using FluentValidation;

namespace Flix.Services.Validators
{
    public class ClashInsertRequestValidator : AbstractValidator<ClashInsertRequest>
    {
        public ClashInsertRequestValidator() {
            RuleFor(x => x.Name)
                .MaximumLength(150)
                .NotEmpty();

            RuleFor(x=>x.Description)
                .MaximumLength(500)
                .NotEmpty();

            RuleFor(x => x.StartDate)
                .NotEmpty()
                .LessThan(x => x.EndDate)
                .WithMessage("Start date must be before end date.")
                .GreaterThanOrEqualTo(DateTime.UtcNow.Date)
                .WithMessage("Start date cannot be in the past.");

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
