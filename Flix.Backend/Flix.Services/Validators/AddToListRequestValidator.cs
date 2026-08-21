using Flix.Model.Enums;
using Flix.Model.Requests;
using FluentValidation;

namespace Flix.Services.Validators
{
    public class AddToListRequestValidator : AbstractValidator<AddToListRequest>
    {
        public AddToListRequestValidator()
        {
            RuleFor(x => x.MovieId)
                .GreaterThan(0)
                .WithMessage("A valid Movie must be sent");

            RuleFor(x => x.Type)
                .Must(type => type is ListType.Custom or ListType.Watchlist)
                .WithMessage("A movie can only be added to a custom list or to the watchlist");

            RuleFor(x => x.ListId)
                .NotNull()
                .GreaterThan(0)
                .When(x => x.Type == ListType.Custom)
                .WithMessage("A valid List must be sent");
        }
    }
}
