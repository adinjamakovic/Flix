using Flix.Model.Requests;
using FluentValidation;
using System;
using System.Collections.Generic;
using System.Text;

namespace Flix.Services.Validators
{
    public class CountryInsertRequestValidator : AbstractValidator<CountryInsertRequest>
    {
        public CountryInsertRequestValidator()
        {
            RuleFor(x => x.Name)
                .MaximumLength(100)
                .NotEmpty();

            RuleFor(x => x.Code)
                .MaximumLength(5);
        }
    }
}
