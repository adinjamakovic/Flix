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
        Task AddToWatchlistAsync(int movieId);
        Task RemoveIfAddedToWatchlistAsync(int movieId);
        Task<bool> IsInWatchlistAsync(int movieId);
    }
}