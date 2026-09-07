using Flix.Model.Requests;
using FluentValidation;

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
