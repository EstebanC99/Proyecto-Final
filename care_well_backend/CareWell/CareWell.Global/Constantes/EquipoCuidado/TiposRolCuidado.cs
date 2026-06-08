namespace CareWell.Global.Constantes.EquipoCuidado
{
    public abstract class TiposRolCuidado
    {
        public const int Responsable = (int)TiposRolCuidadoEnum.Responsable;
        public const int Cuidador = (int)TiposRolCuidadoEnum.Cuidador;

        private enum TiposRolCuidadoEnum
        {
            Responsable = 1,
            Cuidador = 2
        }
    }
}
