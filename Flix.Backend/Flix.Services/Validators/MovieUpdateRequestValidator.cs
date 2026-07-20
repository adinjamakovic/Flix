using Flix.Model.Requests;
using FluentValidation;
using System;
using System.Collections.Generic;
using System.Text;

namespace Flix.Services.Validators
{
    public class MovieUpdateRequestValidator : AbstractValidator<MovieUpdateRequest>
    {
        public MovieUpdateRequestValidator()
        {
            RuleFor(x => x.Title)
                .NotEmpty()
                .MaximumLength(200);

            RuleFor(x => x.DurationMinutes)
                .GreaterThan(0)
                .When(x => x.DurationMinutes.HasValue);

            RuleFor(x => x.CountryId)
                .GreaterThan(0)
                .When(x => x.CountryId.HasValue);

            RuleFor(x => x.LanguageId)
                .GreaterThan(0)
                .When(x => x.LanguageId.HasValue);

            RuleForEach(x => x.GenreIds)
                .GreaterThan(0)
                .When(x => x.GenreIds != null);
        }
    }
}
