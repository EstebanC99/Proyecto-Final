using CareWell.BusinessService.Abstractions.Auth;
using CareWell.DataViews.Auth;
using CareWell.Queries.Auth;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CareWell.API.Controllers.Auth
{
    [AllowAnonymous]
    [ApiController]
    [Route("api/[controller]")]
    public class AuthorizationController : ControllerBase
    {
        private ILoginBusinessService LoginBusinessService { get; set; }
        private IRefrescarTokenBusinessService RefrescarTokenBusinessService { get; set; }

        public AuthorizationController(ILoginBusinessService loginBusinessService,
                                       IRefrescarTokenBusinessService refrescarTokenBusinessService)
        {
            this.LoginBusinessService = loginBusinessService;
            this.RefrescarTokenBusinessService = refrescarTokenBusinessService;
        }

        [HttpPost("login")]
        public LoginDataView Login([FromBody] LoginQuery query)
        {
            return this.LoginBusinessService.Login(query);
        }

        [HttpPost("refresh-token")]
        public LoginDataView Refresh([FromBody] RefrescarTokenQuery query)
        {
            return this.RefrescarTokenBusinessService.Refrescar(query);
        }
    }
}
