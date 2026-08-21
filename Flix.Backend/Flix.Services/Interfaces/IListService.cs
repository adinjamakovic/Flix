using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;

namespace Flix.Services.Interfaces
{
    public interface IListService
        : IBaseCRUDService
        <ListResponse,
        ListSearchObject,
        ListInsertRequest, 
        ListUpdateRequest>
    {
        Task AddToList(AddToListRequest request);
        Task RemoveIfAddedToWatchlistAsync(int movieId);
        Task<bool> IsInWatchlistAsync(int movieId);
    }
}