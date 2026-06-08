namespace CareWell.Global.Constantes.Salud
{
    public abstract class TiposHabitoVida
    {
        public const int ActividadFisica = (int)TiposHabitoVidaEnum.ActividadFisica;
        public const int Alimentacion = (int)TiposHabitoVidaEnum.Alimentacion;
        public const int Sueno = (int)TiposHabitoVidaEnum.Sueno;
        public const int Hidratacion = (int)TiposHabitoVidaEnum.Hidratacion;
        public const int Otro = (int)TiposHabitoVidaEnum.Otro;

        private enum TiposHabitoVidaEnum
        {
            ActividadFisica = 1,
            Alimentacion = 2,
            Sueno = 3,
            Hidratacion = 4,
            Otro = 5,
        }
    }
}
