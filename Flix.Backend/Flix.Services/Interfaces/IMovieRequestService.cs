using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;

namespace Flix.Services.Interfaces
{
    public interface IMovieRequestService : 
        IBaseReadService<MovieRequestResponse, MovieRequestSearchObject>
    {
        Task<MovieRequestResponse> UserRequest(MovieRequestInsertRequest request);
        Task<MovieRequestResponse> AdminReview(int id, MovieRequestUpdateRequest request);
        Task<MovieRequestResponse> Cancel(int id);
    }
}