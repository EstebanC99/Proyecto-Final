using CareWell.BusinessService.Abstractions.Emergencias;
using CareWell.Commands.Emergencias;
using CareWell.DataViews.Emergencias;
using CareWell.Queries.Emergencias;
using Microsoft.AspNetCore.Mvc;

namespace CareWell.API.Controllers.Emergencias
{
    [ApiController]
    [Route("api/[controller]")]
    public class EmergenciaController : ControllerBase
    {
        private IActivarEmergenciaBusinessService ActivarEmergenciaBusinessService { get; set; }

        public EmergenciaController(IActivarEmergenciaBusinessService activarEmergenciaBusinessService)
        {
            this.ActivarEmergenciaBusinessService = activarEmergenciaBusinessService;
        }

        [HttpPost("obtener")]
        public List<EmergenciaDataView> Obtener([FromBody] ObtenerEmergenciasQuery query)
        {
            return this.ActivarEmergenciaBusinessService.Obtener(query);
        }

        [HttpPost("activar")]
        public async Task Activar([FromBody] ActivarEmergenciaCommand command, CancellationToken cancellationToken)
        {
            await this.ActivarEmergenciaBusinessService.Activar(command, cancellationToken);
        }
    }
}
