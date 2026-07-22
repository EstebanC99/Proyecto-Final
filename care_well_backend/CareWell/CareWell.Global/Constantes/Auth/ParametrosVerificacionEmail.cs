namespace CareWell.Global.Constantes.Auth
{
    public abstract class ParametrosVerificacionEmail
    {
        public const int LongitudCodigo = 6;
        public const int MinutosExpiracion = 10;
        public const int MaximoIntentosVerificacion = 5;
        public const int TiempoEsperaReenvioEnSegundos = 60;
        public const int MaximoEnviosPorHora = 5;
    }
}
