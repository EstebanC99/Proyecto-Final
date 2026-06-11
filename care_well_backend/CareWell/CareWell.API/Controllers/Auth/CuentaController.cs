using CareWell.BusinessService.Abstractions.Auth;
using CareWell.Commands.Auth;
using Microsoft.AspNetCore.Mvc;

namespace CareWell.API.Controllers.Auth
{
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
        public IActionResult Crear([FromBody] CrearCuentaCommand command)
        {
            this.CrearCuentaBusinessService.Crear(command);
            return this.NoContent();
        }
    }
}
