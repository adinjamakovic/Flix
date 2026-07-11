namespace Flix.Services.Database
{
    /// <summary>
    /// The role a cast member has on a specific movie credit.
    /// A person can appear in the database as an actor, a director, or both.
    /// </summary>
    public enum CastRole
    {
        Actor = 0,
        Director = 1
    }
}
