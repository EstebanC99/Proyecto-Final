using CareWell.BusinessService.Abstractions.General;
using CareWell.DataViews.General;
using CareWell.Queries.General;
using Microsoft.AspNetCore.Mvc;

namespace CareWell.API.Controllers.General
{
    [ApiController]
    [Route("api/[controller]")]
    public class ResumenDiarioController : ControllerBase
    {
        private IResumenDiarioBusinessService ResumenDiarioBusinessService { get; set; }

        public ResumenDiarioController(IResumenDiarioBusinessService resumenDiarioBusinessService)
        {
            this.ResumenDiarioBusinessService = resumenDiarioBusinessService;
        }

        [HttpPost("generar")]
        public async Task<ResumenDiarioDataView> Generar([FromBody] GenerarResumenDiarioQuery query, CancellationToken cancellationToken)
        {
            return await this.ResumenDiarioBusinessService.Generar(query, cancellationToken);
        }
    }
}
