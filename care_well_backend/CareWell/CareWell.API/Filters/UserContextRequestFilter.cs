using CareWell.Security;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.IdentityModel.JsonWebTokens;
using System.Security.Claims;

namespace CareWell.API.Filters
{
    public class UserContextRequestFilter : IActionFilter
    {
        private readonly IUserContextWriter _userContextWriter;

        public UserContextRequestFilter(IUserContextWriter userContextWriter)
        {
            this._userContextWriter = userContextWriter;
        }

        public void OnActionExecuted(ActionExecutedContext context) { }

        public void OnActionExecuting(ActionExecutingContext context)
        {
            var claim = context.HttpContext.User.FindFirst(JwtRegisteredClaimNames.Sub) ?? context.HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);

            if (claim is not null && int.TryParse(claim.Value, out var id))
                this._userContextWriter.EstablecerUsuario(id);
        }
    }
}
