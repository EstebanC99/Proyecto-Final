using CareWell.BusinessService.Abstractions.Salud;
using CareWell.Commands.Salud;
using CareWell.DataViews.Salud;
using CareWell.Queries.Salud;
using Microsoft.AspNetCore.Mvc;

namespace CareWell.API.Controllers.Salud
{
    [ApiController]
    [Route("api/[controller]")]
    public class AdministrarPersonaEstadoAnimoController : ControllerBase
    {
        private IAdministrarPersonaEstadoAnimoBusinessService AdministrarPersonaEstadoAnimoBusinessService { get; set; }

        public AdministrarPersonaEstadoAnimoController(IAdministrarPersonaEstadoAnimoBusinessService administrarPersonaEstadoAnimoBusinessService)
        {
            this.AdministrarPersonaEstadoAnimoBusinessService = administrarPersonaEstadoAnimoBusinessService;
        }

        [HttpPost("obtener-animo-hoy")]
        public PersonaEstadoAnimoDataView ObtenerAnimoHoy([FromBody] PersonaEstadoAnimoHoyQuery query)
        {
            return this.AdministrarPersonaEstadoAnimoBusinessService.ObtenerAnimoHoy(query);
        }

        [HttpPost("obtener-por-fechas")]
        public List<PersonaEstadoAnimoDataView> ObtenerPorFechas([FromBody] PersonaEstadoAnimoPorFechaQuery query)
        {
            return this.AdministrarPersonaEstadoAnimoBusinessService.ObtenerPorFechas(query);
        }

        [HttpPost("registrar")]
        public void Registrar([FromBody] RegistrarEstadoAnimoCommand command)
        {
            this.AdministrarPersonaEstadoAnimoBusinessService.Registrar(command);
        }
    }
}
