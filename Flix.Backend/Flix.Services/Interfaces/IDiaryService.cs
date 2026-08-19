using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;

namespace Flix.Services.Interfaces
{
    // A diary entry is a Review with IsDiaryEntry set, so it reads back as a ReviewResponse.
    // The diary is only ever read as one user's whole diary, never entry by entry, which is why
    // this does not go through the read/CRUD bases.
    public interface IDiaryService
    {
        Task<PageResult<ReviewResponse>> GetUserDiaryAsync(DiarySearchObject? search);
        Task<ReviewResponse> AddToDiaryAsync(DiaryInsertRequest request);
    }
}
