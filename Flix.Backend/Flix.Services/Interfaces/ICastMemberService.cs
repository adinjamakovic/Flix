using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;

namespace Flix.Services.Interfaces
{
    public interface ICastMemberService : 
        IBaseCRUDService<CastMemberResponse, CastMemberSearchObject, CastMemberInsertRequest, CastMemberUpdateRequest>
    {
    }
}
