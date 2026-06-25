using CareWell.BusinessService.Abstractions.EquipoCuidado;
using CareWell.Commands.EquipoCuidado;
using CareWell.DataViews.EquipoCuidado;
using Microsoft.AspNetCore.Mvc;

namespace CareWell.API.Controllers.EquipoCuidado
{
    [ApiController]
    [Route("api/[controller]")]
    public class AdministrarEquipoCuidadoController : ControllerBase
    {
        private IAdministrarEquipoCuidadoBusinessService AdministrarEquipoCuidadoBusinessService { get; set; }

        public AdministrarEquipoCuidadoController(IAdministrarEquipoCuidadoBusinessService administrarEquipoCuidadoBusinessService)
        {
            this.AdministrarEquipoCuidadoBusinessService = administrarEquipoCuidadoBusinessService;
        }

        [HttpGet("obtener-mis-asignaciones")]
        public List<AsignacionCuidadoDataView> ObtenerAsignacionesPorUsuarioLogueado()
        {
            return this.AdministrarEquipoCuidadoBusinessService.ObtenerAsignacionesUsuarioLogueado();
        }

        [HttpPost("crear-persona-cargo")]
        public void CrearPersonaCargo([FromBody] CrearPersonaCargoCommand command)
        {
            this.AdministrarEquipoCuidadoBusinessService.CrearPersonaCargo(command);
        }
    }
}
