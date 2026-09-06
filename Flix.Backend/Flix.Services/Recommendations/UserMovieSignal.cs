namespace Flix.Services.Recommendations
{
    // Affinity is how strongly the pair says the user wants more of this; IsWatched is whether they
    // have already consumed it. The two are independent: a 1-star review is watched with no
    // affinity, a watchlist add is affinity without having been watched.
    public sealed record UserMovieSignal(int UserId, int MovieId, float Affinity, bool IsWatched);
}
