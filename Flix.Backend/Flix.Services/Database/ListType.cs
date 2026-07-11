namespace Flix.Services.Database
{
    /// <summary>
    /// Distinguishes the special per-user watchlist from custom user lists
    /// and lists that were created for a themed competition.
    /// </summary>
    public enum ListType
    {
        Custom = 0,
        Watchlist = 1,
        Clash = 2
    }
}
