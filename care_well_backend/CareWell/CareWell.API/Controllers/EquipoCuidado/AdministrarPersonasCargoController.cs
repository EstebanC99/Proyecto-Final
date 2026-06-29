using CareWell.BusinessService.Abstractions.EquipoCuidado;
using CareWell.Commands.EquipoCuidado;
using CareWell.DataViews.EquipoCuidado;
using Microsoft.AspNetCore.Mvc;

namespace CareWell.API.Controllers.EquipoCuidado
{
    [ApiController]
    [Route("api/[controller]")]
    public class AdministrarPersonasCargoController : ControllerBase
    {
        private IAdministrarPersonasCargoBusinessService AdministrarPersonasCargoBusinessService { get; set; }

        public AdministrarPersonasCargoController(IAdministrarPersonasCargoBusinessService administrarPersonasCargoBusinessService)
        {
            this.AdministrarPersonasCargoBusinessService = administrarPersonasCargoBusinessService;
        }

        [HttpPost("obtener-mis-asignaciones")]
        public List<AsignacionCuidadoDataView> ObtenerAsignacionesPorUsuarioLogueado()
        {
            return this.AdministrarPersonasCargoBusinessService.ObtenerAsignacionesUsuarioLogueado();
        }

        [HttpPost("crear-persona-cargo")]
        public void CrearPersonaCargo([FromBody] CrearPersonaCargoCommand command)
        {
            this.AdministrarPersonasCargoBusinessService.CrearPersonaCargo(command);
        }

        [HttpPost("modificar-persona-cargo")]
        public void ModificarPersonaCargo([FromBody] ModificarPersonaCargoCommand command)
        {
            this.AdministrarPersonasCargoBusinessService.ModificarPersonaCargo(command);
        }
    }
}
