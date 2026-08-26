using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Interfaces;
using Flix.WebApi.Filters;
using Microsoft.AspNetCore.Mvc;

namespace Flix.WebApi.Controllers
{
    public class LanguageController
        : BaseCRUDController<LanguageResponse, LanguageSearchObject, LanguageInsertRequest, LanguageUpdateRequest, ILanguageService>
    {

        public LanguageController(ILanguageService languageService) : base(languageService)
        {
        }

        [Authorization("Admin")]
        public override Task<ActionResult<LanguageResponse>> Create([FromBody] LanguageInsertRequest request)
        {
            return base.Create(request);
        }

        [Authorization("Admin")]
        public override Task<ActionResult<LanguageResponse>> Update(int id, [FromBody] LanguageUpdateRequest request)
        {
            return base.Update(id, request);
        }

        [Authorization("Admin")]
        public override Task<IActionResult> Delete(int id)
        {
            return base.Delete(id);
        }
    }
}
