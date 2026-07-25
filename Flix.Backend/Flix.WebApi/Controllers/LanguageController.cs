using Flix.Model.Access;
using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Flix.WebApi.Controllers
{
    public class LanguageController
        : BaseCRUDController<LanguageResponse, LanguageSearchObject, LanguageInsertRequest, LanguageUpdateRequest, ILanguageService>
    {

        public LanguageController(ILanguageService languageService) : base(languageService)
        {
        }

        [HttpGet]
        [AllowAnonymous]
        public override async Task<ActionResult<PageResult<LanguageResponse>>> Get([FromQuery] LanguageSearchObject? search)
        {
            return Ok(await _service.GetAsync(search));
        }
    }
}
