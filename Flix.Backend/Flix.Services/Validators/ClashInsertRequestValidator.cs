using Flix.Model.Requests;
using FluentValidation;
using System.Collections.Generic;
using System.Text;

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
                .GreaterThan(DateTime.UtcNow)
                .WithMessage("Start date must be before end date.");

            RuleFor(x => x.EndDate)
                .NotEmpty()
                .GreaterThan(x => x.StartDate)
                .GreaterThan(DateTime.UtcNow)
                .WithMessage("End date must be after start date.");
        }
    }
}
