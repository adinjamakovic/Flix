using Flix.Model.Requests;
using FluentValidation;
using System;
using System.Collections.Generic;
using System.Text;

namespace Flix.Services.Validators
{
    public class LanguageInsertRequestValidator : AbstractValidator<LanguageInsertRequest>
    {
        public LanguageInsertRequestValidator()
        {
            RuleFor(x => x.Name)
                .MaximumLength(60)
                .NotEmpty();

            RuleFor(x => x.Code)
                .MaximumLength(5);
        }
    }
}
