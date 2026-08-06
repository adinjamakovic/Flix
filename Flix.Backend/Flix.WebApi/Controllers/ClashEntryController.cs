using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Interfaces;

namespace Flix.WebApi.Controllers
{
    public class ClashEntryController
        : BaseReadController<ClashEntryResponse, ClashEntrySearchObject, IClashEntryService>
    {
        public ClashEntryController(IClashEntryService service) : base(service)
        {
        }
    }
}
