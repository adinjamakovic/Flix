using Flix.Model.Exceptions;

namespace Flix.Services.StateMachines
{
    public class StatusTransitions<TStatus>(IReadOnlyDictionary<TStatus, IReadOnlyList<TStatus>> allowed)
        where TStatus : struct, Enum
    {
        public bool CanTransition(TStatus from, TStatus to)
            => allowed.TryGetValue(from, out var targets) && targets.Contains(to);

        public bool IsFinal(TStatus status)
            => !allowed.TryGetValue(status, out var targets) || targets.Count == 0;

        // The message is the caller's because it is what the user reads back off a 400.
        public void EnsureCanTransition(TStatus from, TStatus to, string message)
        {
            if (!CanTransition(from, to))
                throw new ClientException(message);
        }

        // The statuses a transition into `to` may start from, for the queries that have to
        // select their candidates in SQL rather than test one entity at a time.
        public IReadOnlyList<TStatus> SourcesOf(TStatus to)
            => [.. allowed.Where(x => x.Value.Contains(to)).Select(x => x.Key)];
    }
}
