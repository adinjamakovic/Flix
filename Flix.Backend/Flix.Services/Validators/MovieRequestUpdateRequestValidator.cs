using Flix.CommonServices.ImageStorageService;
using Flix.Model.Requests;
using FluentValidation;
using System.Collections.Generic;
using System.Text;

namespace Flix.Services.Validators
{
    public class MovieRequestUpdateRequestValidator : AbstractValidator<MovieRequestUpdateRequest>
    {
        private const int MaxNameLength = 50;

        public MovieRequestUpdateRequestValidator()
        {
            Include(new MovieUpdateRequestValidator());

            RuleFor(x => x.DirectorFirstName)
                .NotEmpty()
                .MaximumLength(MaxNameLength)
                .When(x => x.DirectorFirstName is not null);

            RuleFor(x => x.DirectorLastName)
                .MaximumLength(MaxNameLength)
                .When(x => x.DirectorLastName is not null);

            RuleFor(x => x.DirectorCountryId)
                .GreaterThan(0)
                .When(x => x.DirectorCountryId.HasValue);

            RuleFor(x => x.DirectorBirthDate)
                .LessThan(DateTime.UtcNow)
                .When(x => x.DirectorBirthDate.HasValue);

            RuleFor(x => x.DirectorPhoto)
                .ValidImage();
        }
    }
}
