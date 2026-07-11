namespace Flix.Services.Database
{
    /// <summary>
    /// Status of a report raised by a user (either about a movie's details
    /// or about another user's conduct/content).
    /// </summary>
    public enum ReportStatus
    {
        Open = 0,
        Resolved = 1,
        Dismissed = 2
    }
}
