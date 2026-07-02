namespace CareWell.Domain.General
{
    public class TipoEvento : BaseEntity
    {
        public virtual string Descripcion { get; private set; }

        public virtual bool Agendable { get; private set; }
    }
}
