using Flix.CommonServices.ImageStorageService;
using Flix.Model.Requests;
using FluentValidation;

namespace Flix.Services.Validators
{
    public class MovieRequestInsertRequestValidator : AbstractValidator<MovieRequestInsertRequest>
    {
        private const int MaxDirectorNameLength = 101;

        public MovieRequestInsertRequestValidator()
        {
            RuleFor(x => x.Title)
                .NotEmpty()
                .MaximumLength(200);

            RuleFor(x => x.DirectorName)
                .MaximumLength(MaxDirectorNameLength)
                .When(x => !string.IsNullOrWhiteSpace(x.DirectorName));

            RuleFor(x => x.GenreId)
                .GreaterThan(0)
                .When(x => x.GenreId != 0);

            RuleFor(x => x.Poster)
                .ValidImage();
        }
    }
}
