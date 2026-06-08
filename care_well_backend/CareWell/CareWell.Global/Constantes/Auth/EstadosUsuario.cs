namespace CareWell.Global.Constantes.Auth
{
    public abstract class EstadosUsuario
    {
        public const int Activo = (int)EstadosUsuarioEnum.Activo;
        public const int Suspendido = (int)EstadosUsuarioEnum.Suspendido;
        public const int Eliminado = (int)EstadosUsuarioEnum.Eliminado;

        private enum EstadosUsuarioEnum
        {
            Activo = 1,
            Suspendido = 2,
            Eliminado = 3
        }
    }
}
