using CareWell.BusinessService.Abstractions.EquipoCuidado;
using CareWell.Commands.EquipoCuidado;
using CareWell.DataViews.EquipoCuidado;
using CareWell.Queries.EquipoCuidado;
using Microsoft.AspNetCore.Mvc;

namespace CareWell.API.Controllers.EquipoCuidado
{
    [ApiController]
    [Route("/api/[controller]")]
    public class AdministrarEquipoCuidadoController : ControllerBase
    {
        private IAdministrarEquipoCuidadoBusinessService AdministrarEquipoCuidadoBusinessService { get; set; }

        public AdministrarEquipoCuidadoController(IAdministrarEquipoCuidadoBusinessService administrarEquipoCuidadoBusinessService)
        {
            this.AdministrarEquipoCuidadoBusinessService = administrarEquipoCuidadoBusinessService;
        }

        [HttpPost("obtener-asignaciones")]
        public List<AsignacionCuidadoDataView> ObtenerAsignacionesPorPersonaCuidada([FromBody] AsignacionCuidadoQuery query)
        {
            return this.AdministrarEquipoCuidadoBusinessService.ObtenerAsignacionesPorPersonaCuidada(query);
        }

        [HttpPost("asignar")]
        public void Asignar([FromBody] CrearAsignacionCuidadoCommand command)
        {
            this.AdministrarEquipoCuidadoBusinessService.Asignar(command);
        }

        [HttpPost("modificar-permisos-asignacion")]
        public void ModificarPermisos([FromBody] ModificarPermisosAsignacionCommand command)
        {
            this.AdministrarEquipoCuidadoBusinessService.ModificarPermisos(command);
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
