using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Text;

namespace Flix.Services.Interfaces
{
    public interface IBaseReadService<TResponse, TSearch> 
        where TSearch : BaseSearchObject
    {
        Task<TResponse> GetByIdAsync(int id);
        Task<PageResult<TResponse>> GetAsync(TSearch? search = null);
    }
}
