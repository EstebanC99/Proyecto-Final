using CareWell.BusinessService.Abstractions.Salud;
using CareWell.DataViews.Salud;
using CareWell.Queries.Salud;
using Microsoft.AspNetCore.Mvc;

namespace CareWell.API.Controllers.Salud
{
    [ApiController]
    [Route("api/[controller]")]
    public class LineaTiempoSaludController : ControllerBase
    {
        private ILineaTiempoSaludBusinessService LineaTiempoSaludBusinessService { get; set; }

        public LineaTiempoSaludController(ILineaTiempoSaludBusinessService lineaTiempoSaludBusinessService)
        {
            this.LineaTiempoSaludBusinessService = lineaTiempoSaludBusinessService;
        }

        [HttpPost("obtener-por-fechas")]
        public List<EventoBaseDataView> ObtenerPorFechas([FromBody] LineaTiempoSaludQuery query)
        {
            return this.LineaTiempoSaludBusinessService.ObtenerPorFechas(query);
        }
    }
}
