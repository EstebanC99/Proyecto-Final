namespace CareWell.Global.Constantes.EquipoCuidado
{
    public abstract class RolesCuidado
    {
        public const int Responsable = (int)RolesCuidadoEnum.Responsable;
        public const int Cuidador = (int)RolesCuidadoEnum.Cuidador;

        private enum RolesCuidadoEnum
        {
            Responsable = 1,
            Cuidador = 2
        }
    }
}
