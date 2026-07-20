using Flix.Model.Access;
using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Flix.WebApi.Controllers
{
    public class CountryController
        : BaseCRUDController<CountryResponse, CountrySearchObject, CountryInsertRequest, CountryUpdateRequest, ICountryService>
    {

        public CountryController(ICountryService countryService) : base(countryService)
        {
        }

        [HttpGet]
        [AllowAnonymous]
        public override async Task<ActionResult<PageResult<CountryResponse>>> Get([FromQuery] CountrySearchObject? search)
        {
            return Ok(await _service.GetAsync(search));
        }
    }
}
