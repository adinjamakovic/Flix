namespace Flix.Services.Database
{
    /// <summary>
    /// Status of a user-submitted request to add a new movie to the system.
    /// A freshly submitted request is <see cref="Pending"/> (under admin review)
    /// until the administrator approves or rejects it.
    /// </summary>
    public enum MovieRequestStatus
    {
        Pending = 0,
        Approved = 1,
        Rejected = 2
    }
}
