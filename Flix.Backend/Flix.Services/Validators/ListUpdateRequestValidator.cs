using Flix.Model.Requests;
using FluentValidation;

namespace Flix.Services.Validators
{
    public class ListUpdateRequestValidator : AbstractValidator<ListUpdateRequest>
    {
        public ListUpdateRequestValidator()
        {
            RuleFor(x => x.Name)
                .NotEmpty()
                .MaximumLength(150);

            RuleFor(x => x.Description)
                .MaximumLength(500)
                .When(x => !string.IsNullOrWhiteSpace(x.Description));

            RuleForEach(x => x.MovieIds)
                .GreaterThan(0);

            // MovieListItems are uniquely indexed on (MovieListId, MovieId)
            RuleFor(x => x.MovieIds)
                .Must(ids => ids.Distinct().Count() == ids.Count)
                .WithMessage("A movie can only be added to a list once.")
                .When(x => x.MovieIds != null);
        }
    }
}
