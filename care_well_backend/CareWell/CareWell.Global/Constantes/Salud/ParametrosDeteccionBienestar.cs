namespace CareWell.Global.Constantes.Salud
{
    public abstract class ParametrosDeteccionBienestar
    {
        public const int DiasVentanaReciente = 7;
        public const int DiasVentanaBase = 30;

        public const int MinRegistrosConsecutivosAnimoBajo = 3;
        public const int DiasLapsoMaximoAnimoBajo = 10;

        public const int MinRegistrosAnimoReciente = 3;
        public const int MinRegistrosAnimoBase = 5;
        public const double DeltaDeterioroAnimo = 1.0;

        public const int DiasAntiguedadMinimaHabito = 14;
        public const int MinRealizacionesBaseHabito = 4;

        public const double UmbralCaidaCumplimiento = 0.5;
    }
}
