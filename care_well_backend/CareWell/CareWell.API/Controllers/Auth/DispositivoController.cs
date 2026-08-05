using CareWell.BusinessService.Abstractions.Auth;
using CareWell.Commands.Auth;
using Microsoft.AspNetCore.Mvc;

namespace CareWell.API.Controllers.Auth
{
    [ApiController]
    [Route("api/[controller]")]
    public class DispositivoController : ControllerBase
    {
        private IAdministrarDispositivoBusinessService AdministrarDispositivoBusinessService { get; set; }

        public DispositivoController(IAdministrarDispositivoBusinessService administrarDispositivoBusinessService)
        {
            this.AdministrarDispositivoBusinessService = administrarDispositivoBusinessService;
        }

        [HttpPost("registrar")]
        public void Registrar([FromBody] RegistrarDispositivoCommand command)
        {
            this.AdministrarDispositivoBusinessService.Registrar(command);
        }

        [HttpPost("eliminar")]
        public void Eliminar([FromBody] EliminarDispositivoCommand command)
        {
            this.AdministrarDispositivoBusinessService.Eliminar(command);
        }
    }
}
