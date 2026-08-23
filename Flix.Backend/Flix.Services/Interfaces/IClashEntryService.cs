using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;

namespace Flix.Services.Interfaces
{
    public interface IClashEntryService : IBaseReadService<ClashEntryResponse, ClashEntrySearchObject>
    {
        Task Participate(ClashEntryInsertRequest request);
        Task<ClashVoteStateResponse> GetVoteStateAsync(int clashId);
        Task Vote(int clashEntryId);
        Task RemoveVote(int clashEntryId);
    }
}
