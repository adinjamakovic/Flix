using Flix.Model.Enums;
using Flix.Model.Requests;
using FluentValidation;

namespace Flix.Services.Validators
{
    // The feed renders an activity off the reference it carries, so an activity without that
    // reference is a row nothing can display - a WatchedMovie with no movie, a FollowedUser with
    // nobody followed. Which reference is required is decided by the type, and nothing else here
    // is: the extra ids are legitimate context (a JoinedClash also names the list that entered).
    public class ActivityInsertRequestValidator : AbstractValidator<ActivityInsertRequest>
    {
        private static readonly ActivityType[] MovieActivities =
        {
            ActivityType.WatchedMovie,
            ActivityType.ReviewedMovie,
            ActivityType.LikedMovie,
            ActivityType.AddedToWatchlist
        };

        private static readonly ActivityType[] ClashActivities =
        {
            ActivityType.JoinedClash,
            ActivityType.WonClash,
            ActivityType.VotedOnClash
        };

        public ActivityInsertRequestValidator()
        {
            RuleFor(x => x.Type)
                .IsInEnum();

            RuleFor(x => x.MovieId)
                .NotNull()
                .When(x => MovieActivities.Contains(x.Type))
                .WithMessage("This activity has to name the movie it happened to.");

            RuleFor(x => x.ReviewId)
                .NotNull()
                .When(x => x.Type == ActivityType.ReviewedMovie)
                .WithMessage("A review activity has to name the review.");

            RuleFor(x => x.MovieListId)
                .NotNull()
                .When(x => x.Type == ActivityType.CreatedList)
                .WithMessage("A list activity has to name the list.");

            RuleFor(x => x.ClashId)
                .NotNull()
                .When(x => ClashActivities.Contains(x.Type))
                .WithMessage("This activity has to name the clash it happened in.");

            RuleFor(x => x.TargetUserId)
                .NotNull()
                .When(x => x.Type == ActivityType.FollowedUser)
                .WithMessage("A follow activity has to name the user that was followed.");

            RuleFor(x => x.MovieId)
                .GreaterThan(0)
                .When(x => x.MovieId.HasValue);

            RuleFor(x => x.ReviewId)
                .GreaterThan(0)
                .When(x => x.ReviewId.HasValue);

            RuleFor(x => x.ClashId)
                .GreaterThan(0)
                .When(x => x.ClashId.HasValue);

            RuleFor(x => x.MovieListId)
                .GreaterThan(0)
                .When(x => x.MovieListId.HasValue);

            RuleFor(x => x.TargetUserId)
                .GreaterThan(0)
                .When(x => x.TargetUserId.HasValue);
        }
    }
}
