using Flix.Model.SearchObjects;

namespace Flix.Services.Interfaces
{
    public interface IBaseCRUDService<TResponse, TSearch, TInsertRequest, TUpdateRequest>
        : IBaseReadService<TResponse, TSearch>
        where TSearch : BaseSearchObject
    {
        Task<TResponse> InsertAsync(TInsertRequest request);
        Task<TResponse> UpdateAsync(int id, TUpdateRequest request);
        Task DeleteAsync(int id);
    }
}
