namespace CareWell.Domain.EquipoCuidado
{
    public class PermisoCuidado : BaseEntity
    {
        public virtual string Descripcion { get; private set; }

        public virtual RolCuidado Rol { get; private set; }
    }
}
