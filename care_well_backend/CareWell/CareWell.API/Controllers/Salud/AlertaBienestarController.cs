using CareWell.BusinessService.Abstractions.Salud;
using CareWell.DataViews.Salud;
using CareWell.Queries.Salud;
using Microsoft.AspNetCore.Mvc;

namespace CareWell.API.Controllers.Salud
{
    [ApiController]
    [Route("api/[controller]")]
    public class AlertaBienestarController : ControllerBase
    {
        private IAlertaBienestarBusinessService AlertasBienestarBusinessService { get; set; }

        public AlertaBienestarController(IAlertaBienestarBusinessService alertasBienestarBusinessService)
        {
            this.AlertasBienestarBusinessService = alertasBienestarBusinessService;
        }

        [HttpPost("obtener")]
        public List<AlertaBienestarDataView> Obtener([FromBody] AlertaBienestarQuery query)
        {
            return this.AlertasBienestarBusinessService.Obtener(query);
        }
    }
}
