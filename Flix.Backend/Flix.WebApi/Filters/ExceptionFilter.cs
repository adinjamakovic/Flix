using System.Net;
using Flix.Model.Exceptions;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;

namespace Flix.WebApi.Filters
{
    public class ExceptionFilter : ExceptionFilterAttribute
    {
        private readonly ILogger<ExceptionFilter> _logger;

        public ExceptionFilter(ILogger<ExceptionFilter> logger)
        {
            _logger = logger;
        }

        public override void OnException(ExceptionContext context)
        {
            _logger.LogError(context.Exception, "An exception occured");

            if(context.Exception is FluentValidation.ValidationException fvEx)
            {
                foreach(var error in fvEx.Errors)
                    context.ModelState.AddModelError(error.PropertyName ?? string.Empty, error.ErrorMessage);
                
                context.HttpContext.Response.StatusCode = (int)HttpStatusCode.BadRequest;
            }
            else if(context.Exception is ClientException)
            {
                context.ModelState.AddModelError("clientError", context.Exception.Message);
                context.HttpContext.Response.StatusCode = (int)HttpStatusCode.BadRequest;
            }
            else
            {
                context.ModelState.AddModelError("serverError", "Server side error, please check logs");
                context.HttpContext.Response.StatusCode = (int)HttpStatusCode.InternalServerError;
            }

            var list = context.ModelState.Where(x => x.Value.Errors.Count > 0)
                        .ToDictionary(c => c.Key, c=> c.Value.Errors.Select(x=>x.ErrorMessage));
            
            context.Result = new JsonResult(new
            {
                errors = list
            });
        }
    }
}