using CareWell.BusinessService.Abstractions.General;
using CareWell.DataViews.General;
using Microsoft.AspNetCore.Mvc;

namespace CareWell.API.Controllers.General
{
    [ApiController]
    [Route("api/[controller]")]
    public class AdministrarTipoEventoController : ControllerBase
    {
        private IAdministrarTipoEventoBusinessService AdministrarTipoEventoBusinessService { get; set; }

        public AdministrarTipoEventoController(IAdministrarTipoEventoBusinessService administrarTipoEventoBusinessService)
        {
            this.AdministrarTipoEventoBusinessService = administrarTipoEventoBusinessService;
        }

        [HttpPost("obtener-todos")]
        public List<TipoEventoDataView> ObtenerTodos()
        {
            return this.AdministrarTipoEventoBusinessService.ObtenerTodos();
        }
    }
}
