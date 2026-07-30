using CareWell.BusinessService.Abstractions.Salud;
using CareWell.DataViews;
using Microsoft.AspNetCore.Mvc;

namespace CareWell.API.Controllers.Salud
{
    [ApiController]
    [Route("api/[controller]")]
    public class AdministrarTipoHabitoVidaController : ControllerBase
    {
        private IAdministrarTipoHabitoVidaBusinessService AdministrarTipoHabitoVidaBusinessService { get; set; }

        public AdministrarTipoHabitoVidaController(IAdministrarTipoHabitoVidaBusinessService administrarTipoHabitoVidaBusinessService)
        {
            this.AdministrarTipoHabitoVidaBusinessService = administrarTipoHabitoVidaBusinessService;
        }

        [HttpPost("obtener-todos")]
        public List<BaseEntityDataView> ObtenerTodos()
        {
            return this.AdministrarTipoHabitoVidaBusinessService.ObtenerTodos();
        }
    }
}
