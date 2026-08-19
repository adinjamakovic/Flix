using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Implementations;
using Flix.Services.Interfaces;
using Flix.WebApi.Filters;
using Microsoft.AspNetCore.Mvc;

namespace Flix.WebApi.Controllers
{
    public class ListController
        : BaseCRUDController<ListResponse, ListSearchObject, ListInsertRequest, ListUpdateRequest, IListService>
    {

        public ListController(IListService listService) : base(listService)
        {
        }
    }
}