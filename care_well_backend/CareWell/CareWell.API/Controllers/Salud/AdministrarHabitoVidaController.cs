using CareWell.BusinessService.Abstractions.Salud;
using CareWell.Commands.Salud;
using CareWell.DataViews.Salud;
using CareWell.Queries.Salud;
using Microsoft.AspNetCore.Mvc;

namespace CareWell.API.Controllers.Salud
{
    [ApiController]
    [Route("api/[controller]")]
    public class AdministrarHabitoVidaController : ControllerBase
    {
        private IAdministrarHabitoVidaBusinessService AdministrarHabitoVidaBusinessService { get; set; }

        public AdministrarHabitoVidaController(IAdministrarHabitoVidaBusinessService administrarHabitoVidaBusinessService)
        {
            this.AdministrarHabitoVidaBusinessService = administrarHabitoVidaBusinessService;
        }

        [HttpPost("obtener-todos")]
        public List<HabitoVidaDataView> ObtenerTodos([FromBody] HabitoVidaQuery query)
        {
            return this.AdministrarHabitoVidaBusinessService.ObtenerTodos(query);
        }

        [HttpPost("obtener-realizaciones")]
        public List<HabitoVidaRealizacionDataView> ObtenerRealizaciones([FromBody] HabitoVidaQuery query)
        {
            return this.AdministrarHabitoVidaBusinessService.ObtenerRealizacionesPorFecha(query);
        }

        [HttpPost("crear")]
        public void Crear([FromBody] CrearHabitoVidaCommand command)
        {
            this.AdministrarHabitoVidaBusinessService.Crear(command);
        }

        [HttpPost("modificar")]
        public void Modificar([FromBody] ModificarHabitoVidaCommand command)
        {
            this.AdministrarHabitoVidaBusinessService.Modificar(command);
        }

        [HttpPost("eliminar")]
        public void Eliminar([FromBody] int habitoVidaID)
        {
            this.AdministrarHabitoVidaBusinessService.Eliminar(habitoVidaID);
        }

        [HttpPost("crear-realizacion")]
        public void CrearRealizacion([FromBody] CrearRealizacionHabitoVidaCommand command)
        {
            this.AdministrarHabitoVidaBusinessService.CrearRealizacion(command);
        }

        [HttpPost("modificar-realizacion")]
        public void ModificarRealizacion([FromBody] ModificarRealizacionHabitoVidaCommand command)
        {
            this.AdministrarHabitoVidaBusinessService.ModificarRealizacion(command);
        }

        [HttpPost("eliminar-realizacion")]
        public void EliminarRealizacion([FromBody] EliminarRealizacionHabitoVidaCommand command)
        {
            this.AdministrarHabitoVidaBusinessService.EliminarRealizacion(command);
        }
    }
}
