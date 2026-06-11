using CareWell.BusinessService.Abstractions.Auth;
using CareWell.Queries.Auth;
using Microsoft.AspNetCore.Mvc;

namespace CareWell.API.Controllers.Auth
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthorizationController : ControllerBase
    {
        private ILoginBusinessService LoginBusinessService { get; set; }

        public AuthorizationController(ILoginBusinessService loginBusinessService)
        {
            this.LoginBusinessService = loginBusinessService;
        }

        [HttpPost("login")]
        public IActionResult Login([FromBody] LoginQuery query)
        {
            try
            {
                var loginDataView = this.LoginBusinessService.Login(query);
                return this.Ok(loginDataView);
            }
            catch (UnauthorizedAccessException)
            {
                return Unauthorized(new { mensaje = "Credenciales inválidas." });
            }
        }
    }
}
