using Flix.Model.Requests;
using FluentValidation;
using System;
using System.Collections.Generic;
using System.Text;

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
        }
    }
}
