using CareWell.DataViews.General;

namespace CareWell.DataViews.Auth
{
    public class UsuarioDataView : BaseDataView
    {
        public string NombreUsuario { get; set; }

        public EstadoUsuarioDataView Estado { get; set; }

        public PersonaDataView Persona { get; set; }
    }
}
