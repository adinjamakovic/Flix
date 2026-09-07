using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;

namespace Flix.Services.Interfaces
{
    public interface IClashService : 
        IBaseCRUDService<ClashResponse, ClashSearchObject, ClashInsertRequest, ClashUpdateRequest>
    {
    }
}
