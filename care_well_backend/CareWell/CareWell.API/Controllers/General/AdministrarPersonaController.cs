using CareWell.BusinessService.Abstractions.General;
using CareWell.Commands.General;
using Microsoft.AspNetCore.Mvc;

namespace CareWell.API.Controllers.General
{
    [ApiController]
    [Route("api/[controller]")]
    public class AdministrarPersonaController : ControllerBase
    {
        private IAdministrarPersonaBusinessService AdministrarPersonaBusinessService { get; set; }

        public AdministrarPersonaController(IAdministrarPersonaBusinessService administrarPersonaBusinessService)
        {
            this.AdministrarPersonaBusinessService = administrarPersonaBusinessService;
        }

        [HttpPost("modificar-perfil")]
        public void ModificarPerfil([FromBody] ModificarPerfilCommand command)
        {
            this.AdministrarPersonaBusinessService.ModificarPerfil(command);
        }

        [HttpGet("{id:int}/imagen")]
        public IActionResult ObtenerImagenPerfil(int id)
        {
            var imagen = this.AdministrarPersonaBusinessService.ObtenerImagenPerfil(id);

            if (imagen.Contenido is null)
                return NotFound();

            return File(imagen.Contenido, imagen.TipoContenido);
        }
    }
}
