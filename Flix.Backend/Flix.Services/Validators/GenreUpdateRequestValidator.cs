using Flix.Model.Requests;
using FluentValidation;
using System;
using System.Collections.Generic;
using System.Text;

namespace Flix.Services.Validators
{
    public class GenreUpdateRequestValidator : AbstractValidator<GenreUpdateRequest>
    {
        public GenreUpdateRequestValidator()
        {
            RuleFor(x => x.Name)
                .MaximumLength(50);
        }
    }
}
