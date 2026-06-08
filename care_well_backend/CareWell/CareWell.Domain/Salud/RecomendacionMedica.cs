using CareWell.Domain.General;

namespace CareWell.Domain.Salud
{
    public class RecomendacionMedica : BaseEntity
    {
        public virtual Persona Persona { get; private set; }

        public virtual string Descripcion { get; private set; }

        public virtual DateTime FechaHora { get; private set; }

        public virtual string NombreProfesional { get; private set; }
    }
}
