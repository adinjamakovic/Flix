namespace Flix.Model.Responses
{
    public class ClashVoteStateResponse
    {
        public int ClashId { get; set; }
        public int VotesAllowed { get; set; }
        public int VotesUsed { get; set; }
        public int VotesRemaining { get; set; }
        public List<int> VotedEntryIds { get; set; } = [];
    }
}
