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
        private IVerificacionEmailBusinessService VerificacionEmailBusinessService { get; set; }

        public CuentaController(ICrearCuentaBusinessService crearCuentaBusinessService,
                                IVerificacionEmailBusinessService verificacionEmailBusinessService)
        {
            this.CrearCuentaBusinessService = crearCuentaBusinessService;
            this.VerificacionEmailBusinessService = verificacionEmailBusinessService;
        }

        [HttpPost("crear")]
        public void Crear([FromBody] CrearCuentaCommand command)
        {
            this.CrearCuentaBusinessService.Crear(command);
        }

        [HttpPost("reenviar-codigo")]
        public void ReenviarCodigo([FromBody] EnviarCodigoVerificacionEmailCommand command)
        {
            this.VerificacionEmailBusinessService.EnviarCodigo(command);
        }

        [HttpPost("verificar-email")]
        public void VerificarEmail([FromBody] VerificarEmailCommand command)
        {
            this.VerificacionEmailBusinessService.Verificar(command);
        }
    }
}
