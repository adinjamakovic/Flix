using System.Security.Claims;
using Flix.Services.Database;
using Flix.WebApi.Services.AccessManager;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;

namespace Flix.WebApi.Filters
{
    public class AuthorizationAttribute : TypeFilterAttribute
    {
        public AuthorizationAttribute(params string[] roles) : base(typeof(AuthorizationFilter))
        {
            Arguments = new object[] { roles };
        }

        public class AuthorizationFilter : IAuthorizationFilter
        {
            private readonly string[] _roles;
            
            public AuthorizationFilter(params string[] roles)
            {
                _roles = roles;
            }

            public void OnAuthorization(AuthorizationFilterContext context)
            {
                var userRole = context.HttpContext.User.Claims.FirstOrDefault(x => x.Type == ClaimNames.Role || x.Type == "role")?.Value;

                if(userRole == null || !_roles.Any(x => x == userRole))
                    context.Result = new ForbidResult();
            }

        }    
         
    }

      
}
