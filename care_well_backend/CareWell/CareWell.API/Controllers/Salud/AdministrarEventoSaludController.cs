using CareWell.BusinessService.Abstractions.Salud;
using CareWell.Commands.Salud;
using CareWell.DataViews.Salud;
using CareWell.Queries.Salud;
using Microsoft.AspNetCore.Mvc;

namespace CareWell.API.Controllers.Salud
{
    [ApiController]
    [Route("api/[controller]")]
    public class AdministrarEventoSaludController : ControllerBase
    {
        private IAdministrarEventoSaludBusinessService AdministrarEventoSaludBusinessService { get; set; }

        public AdministrarEventoSaludController(IAdministrarEventoSaludBusinessService administrarEventoSaludBusinessService)
        {
            this.AdministrarEventoSaludBusinessService = administrarEventoSaludBusinessService;
        }

        [HttpPost("obtener-todos")]
        public List<EventoSaludDataView> ObtenerTodos([FromBody] EventoSaludQuery query)
        {
            return this.AdministrarEventoSaludBusinessService.ObtenerTodos(query);
        }

        [HttpPost("crear")]
        public void Crear([FromBody] CrearEventoSaludCommand command)
        {
            this.AdministrarEventoSaludBusinessService.Crear(command);
        }

        [HttpPost("eliminar")]
        public void Eliminar([FromBody] int eventoSaludID)
        {
            this.AdministrarEventoSaludBusinessService.Eliminar(eventoSaludID);
        }

        [HttpPost("agregar-nota")]
        public void AgregarNota([FromBody] CrearNotaEventoSaludCommand command)
        {
            this.AdministrarEventoSaludBusinessService.AgregarNota(command);
        }

        [HttpPost("modificar-nota")]
        public void ModificarNota([FromBody] ModificarNotaEventoSaludCommand command)
        {
            this.AdministrarEventoSaludBusinessService.ModificarNota(command);
        }

        [HttpPost("eliminar-nota")]
        public void EliminarNota([FromBody] EliminarNotaEventoSaludCommand command)
        {
            this.AdministrarEventoSaludBusinessService.EliminarNota(command);
        }
    }
}
