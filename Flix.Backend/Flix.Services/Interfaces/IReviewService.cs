using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Text;

namespace Flix.Services.Interfaces
{
    public interface IReviewService : IBaseReadService<ReviewResponse, ReviewSearchObject>
    {
    }
}
