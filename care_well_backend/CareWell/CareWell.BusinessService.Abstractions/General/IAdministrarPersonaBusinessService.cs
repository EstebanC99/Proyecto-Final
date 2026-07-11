using CareWell.Commands.General;
using CareWell.DataViews.General;

namespace CareWell.BusinessService.Abstractions.General
{
    public interface IAdministrarPersonaBusinessService
    {
        void ModificarPerfil(ModificarPerfilCommand command);
        PersonaImagenDataView ObtenerImagenPerfil(int personaID);
    }
}
