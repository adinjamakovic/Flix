using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;

namespace Flix.Services.Interfaces
{
    public interface IStudioService :
        IBaseCRUDService<StudioResponse, StudioSearchObject, StudioInsertRequest, StudioUpdateRequest>
    {
    }
}
