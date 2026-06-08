using CareWell.Domain.General;

namespace CareWell.Domain.EquipoCuidado
{
    public class AsignacionCuidado : BaseEntity
    {
        public virtual Persona PersonaCuidada { get; private set; }

        public virtual Persona Colaborador { get; private set; }

        public virtual RolCuidado Rol { get; private set; }

        public virtual EstadoAsignacionCuidado Estado { get; private set; }

        public virtual DateTime FechaAlta { get; private set; }
    }
}
