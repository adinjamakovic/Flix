namespace Flix.Services.Database
{
    /// <summary>
    /// Type of activity recorded in a user's activity stream. Drives the
    /// "Recent Activity" admin widget and the friends/following feed.
    /// </summary>
    public enum ActivityType
    {
        JoinedPlatform = 0,
        WatchedMovie = 1,
        ReviewedMovie = 2,
        LikedMovie = 3,
        AddedToWatchlist = 4,
        CreatedList = 5,
        FollowedUser = 6,
        RequestedMovie = 7,
        JoinedClash = 8,
        WonClash = 9
    }
}
