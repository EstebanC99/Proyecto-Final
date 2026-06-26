using CareWell.DataViews.General;

namespace CareWell.DataViews.EquipoCuidado
{
    public class AsignacionCuidadoDataView : BaseDataView
    {
        public PersonaDataView Persona { get; set; }

        public PersonaDataView Colaborador { get; set; }

        public BaseEntityDataView Rol { get; set; }

        public BaseEntityDataView Estado { get; set; }

        public DateTime FechaAlta { get; set; }

        public List<BaseEntityDataView> Permisos { get; set; }

        public DateTime? FechaEliminacion { get; set; }
    }
}
