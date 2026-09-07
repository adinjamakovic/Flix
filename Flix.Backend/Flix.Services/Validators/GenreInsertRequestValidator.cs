using Flix.Model.Requests;
using FluentValidation;

namespace Flix.Services.Validators
{
    public class GenreInsertRequestValidator : AbstractValidator<GenreInsertRequest>
    {
        public GenreInsertRequestValidator()
        {
            RuleFor(x => x.Name)
                .MaximumLength(50)
                .NotEmpty();
        }
    }
}
