namespace CareWell.Domain.EquipoCuidado
{
    public class RolCuidado : BaseEntity
    {
        public virtual TipoRolCuidado Tipo { get; private set; }

        public virtual List<PermisoCuidado> Permisos { get; private set; }
    }
}
