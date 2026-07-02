using CareWell.BusinessService.Abstractions.Agenda;
using CareWell.Commands.Agenda;
using CareWell.DataViews.Agenda;
using CareWell.Queries.Agenda;
using Microsoft.AspNetCore.Mvc;

namespace CareWell.API.Controllers.Agenda
{
    [ApiController]
    [Route("api/[controller]")]
    public class AdministrarEventoAgendaController : ControllerBase
    {
        private IAdministrarEventoAgendaBusinessService AdministrarEventoAgendaBusinessService { get; set; }

        public AdministrarEventoAgendaController(IAdministrarEventoAgendaBusinessService administrarEventoAgendaBusinessService)
        {
            this.AdministrarEventoAgendaBusinessService = administrarEventoAgendaBusinessService;
        }

        [HttpPost("obtener-ocurrencias")]
        public List<OcurrenciaEventoAgendaDataView> ObtenerOcurrencias([FromBody] ObtenerEventosAgendaQuery query)
        {
            return this.AdministrarEventoAgendaBusinessService.ObtenerOcurrencias(query);
        }

        [HttpPost("crear")]
        public void Crear([FromBody] CrearEventoAgendaCommand command)
        {
            this.AdministrarEventoAgendaBusinessService.Crear(command);
        }

        [HttpPost("modificar")]
        public void Modificar([FromBody] ModificarEventoAgendaCommand command)
        {
            this.AdministrarEventoAgendaBusinessService.Modificar(command);
        }

        [HttpPost("eliminar")]
        public void Eliminar([FromBody] int eventoAgendaID)
        {
            this.AdministrarEventoAgendaBusinessService.Eliminar(eventoAgendaID);
        }

        [HttpPost("cancelar-ocurrencia")]
        public void CancelarOcurrencia([FromBody] CancelarOcurrenciaEventoAgendaCommand command)
        {
            this.AdministrarEventoAgendaBusinessService.CancelarOcurrencia(command);
        }
    }
}
