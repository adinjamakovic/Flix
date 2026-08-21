using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Text;

namespace Flix.Services.Interfaces
{
    public interface IReviewService : IBaseReadService<ReviewResponse, ReviewSearchObject>
    {
        // Reviews are written by users, never by an admin, so this is read + delete
        // rather than the full CRUD contract.
        Task DeleteAsync(int id);
        Task<PageResult<ReviewResponse>> GetLatestReviewsFromFriendsAsync(int userId);
        Task<ReviewCountResponse> GetReviewCountAsync(ReviewCountSearchObject? search);
        Task<MovieUserStateResponse> GetMovieStateAsync(int movieId);
        Task<MovieUserStateResponse> UpsertStandingReviewAsync(ReviewUpsertRequest request);
    }
}
