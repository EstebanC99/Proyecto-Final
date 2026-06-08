namespace CareWell.Global.Constantes.EquipoCuidado
{
    public abstract class EstadosAsignacionCuidado
    {
        public const int Activa = (int)EstadosAsignacionCuidadoEnum.Activa;
        public const int Inactiva = (int)EstadosAsignacionCuidadoEnum.Inactiva;
        public const int Pendiente = (int)EstadosAsignacionCuidadoEnum.Pendiente;

        private enum EstadosAsignacionCuidadoEnum
        {
            Activa = 1,
            Inactiva = 2,
            Pendiente = 3
        }
    }
}
