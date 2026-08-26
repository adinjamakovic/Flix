using Flix.Model.Enums;

namespace Flix.Services.StateMachines
{
    public static class Transitions
    {
        public static readonly StatusTransitions<MovieRequestStatus> MovieRequest =
            new(new Dictionary<MovieRequestStatus, IReadOnlyList<MovieRequestStatus>>
            {
                [MovieRequestStatus.Pending] =
                [
                    MovieRequestStatus.Approved,
                    MovieRequestStatus.Rejected,
                    MovieRequestStatus.Cancelled
                ],
                [MovieRequestStatus.Approved] = [],
                [MovieRequestStatus.Rejected] = [],
                [MovieRequestStatus.Cancelled] = []
            });

        // Neither outcome is final: the admin can change their mind on a report they have
        // already closed, which is what the desktop card's "Update outcome" does.
        public static readonly StatusTransitions<ReportStatus> Report =
            new(new Dictionary<ReportStatus, IReadOnlyList<ReportStatus>>
            {
                [ReportStatus.Open] = [ReportStatus.Resolved, ReportStatus.Dismissed],
                [ReportStatus.Resolved] = [ReportStatus.Dismissed],
                [ReportStatus.Dismissed] = [ReportStatus.Resolved]
            });

        public static readonly StatusTransitions<ClashStatus> Clash =
            new(new Dictionary<ClashStatus, IReadOnlyList<ClashStatus>>
            {
                [ClashStatus.Upcoming] = [ClashStatus.Active, ClashStatus.Completed],
                [ClashStatus.Active] = [ClashStatus.Completed],
                [ClashStatus.Completed] = []
            });
    }
}
