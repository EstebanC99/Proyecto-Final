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
        private IAdministrarPersonasCargoBusinessService AdministrarEquipoCuidadoBusinessService { get; set; }

        public AdministrarPersonasCargoController(IAdministrarPersonasCargoBusinessService administrarEquipoCuidadoBusinessService)
        {
            this.AdministrarEquipoCuidadoBusinessService = administrarEquipoCuidadoBusinessService;
        }

        [HttpPost("obtener-mis-asignaciones")]
        public List<AsignacionCuidadoDataView> ObtenerAsignacionesPorUsuarioLogueado()
        {
            return this.AdministrarEquipoCuidadoBusinessService.ObtenerAsignacionesUsuarioLogueado();
        }

        [HttpPost("crear-persona-cargo")]
        public void CrearPersonaCargo([FromBody] CrearPersonaCargoCommand command)
        {
            this.AdministrarEquipoCuidadoBusinessService.CrearPersonaCargo(command);
        }

        [HttpPost("modificar-persona-cargo")]
        public void CrearPersonaCargo([FromBody] ModificarPersonaCargoCommand command)
        {
            this.AdministrarEquipoCuidadoBusinessService.ModificarPersonaCargo(command);
        }

        [HttpPost("eliminar-asignacion")]
        public void EliminarAsignacion([FromBody] int asignacionID)
        {
            this.AdministrarEquipoCuidadoBusinessService.EliminarAsignacion(asignacionID);
        }

        [HttpPost("activar-asignacion")]
        public void ActivarAsignacion([FromBody] int asignacionID)
        {
            this.AdministrarEquipoCuidadoBusinessService.ActivarAsignacion(asignacionID);
        }

        [HttpPost("reactivar-asignacion")]
        public void ReactivarAsignacion([FromBody] int asignacionID)
        {
            this.AdministrarEquipoCuidadoBusinessService.ReactivarAsignacion(asignacionID);
        }
    }
}
