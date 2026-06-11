using CareWell.BusinessService.Abstractions.Auth;
using CareWell.Commands.Auth;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CareWell.API.Controllers.Auth
{
    [AllowAnonymous]
    [ApiController]
    [Route("api/[controller]")]
    public class CuentaController : ControllerBase
    {
        private ICrearCuentaBusinessService CrearCuentaBusinessService { get; set; }

        public CuentaController(ICrearCuentaBusinessService crearCuentaBusinessService)
        {
            this.CrearCuentaBusinessService = crearCuentaBusinessService;
        }

        [HttpPost("crear")]
        public void Crear([FromBody] CrearCuentaCommand command)
        {
            this.CrearCuentaBusinessService.Crear(command);
        }
    }
}
