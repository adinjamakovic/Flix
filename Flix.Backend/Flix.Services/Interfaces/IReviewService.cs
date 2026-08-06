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
    }
}
