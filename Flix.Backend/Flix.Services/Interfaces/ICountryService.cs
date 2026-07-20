using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Text;

namespace Flix.Services.Interfaces
{
    public interface ICountryService :
        IBaseCRUDService<CountryResponse, CountrySearchObject, CountryInsertRequest, CountryUpdateRequest>
    {
    }
}
