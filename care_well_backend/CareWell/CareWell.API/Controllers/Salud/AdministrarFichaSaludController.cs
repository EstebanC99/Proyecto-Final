using CareWell.BusinessService.Abstractions.Salud;
using CareWell.Commands.Salud;
using CareWell.DataViews.Salud;
using CareWell.Queries.Salud;
using Microsoft.AspNetCore.Mvc;

namespace CareWell.API.Controllers.Salud
{
    [ApiController]
    [Route("api/[controller]")]
    public class AdministrarFichaSaludController : ControllerBase
    {
        private IAdministrarFichaSaludBusinessService AdministrarFichaSaludBusinessService { get; set; }

        public AdministrarFichaSaludController(IAdministrarFichaSaludBusinessService administrarFichaSaludBusinessService)
        {
            this.AdministrarFichaSaludBusinessService = administrarFichaSaludBusinessService;
        }

        [HttpPost("obtener")]
        public FichaSaludDataView Obtener([FromBody] FichaSaludQuery query)
        {
            return this.AdministrarFichaSaludBusinessService.Obtener(query);
        }

        [HttpPost("crear")]
        public void Crear([FromBody] CrearFichaSaludCommand command)
        {
            this.AdministrarFichaSaludBusinessService.Crear(command);
        }

        [HttpPost("modificar")]
        public void Modificar([FromBody] ModificarFichaSaludCommand command)
        {
            this.AdministrarFichaSaludBusinessService.Modificar(command);
        }
    }
}
