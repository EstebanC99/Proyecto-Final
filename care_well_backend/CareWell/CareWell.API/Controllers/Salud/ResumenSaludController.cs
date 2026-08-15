using CareWell.BusinessService.Abstractions.Salud;
using CareWell.DataViews.Salud;
using CareWell.Queries.Salud;
using Microsoft.AspNetCore.Mvc;

namespace CareWell.API.Controllers.Salud
{
    [ApiController]
    [Route("api/[controller]")]
    public class ResumenSaludController : ControllerBase
    {
        private IResumenSaludBusinessService ResumenSaludBusinessService { get; set; }

        public ResumenSaludController(IResumenSaludBusinessService resumenSaludBusinessService)
        {
            this.ResumenSaludBusinessService = resumenSaludBusinessService;
        }

        [HttpPost("obtener")]
        public ResumenSaludDataView Obtener([FromBody] ResumenSaludQuery query)
        {
            return this.ResumenSaludBusinessService.Obtener(query);
        }
    }
}
