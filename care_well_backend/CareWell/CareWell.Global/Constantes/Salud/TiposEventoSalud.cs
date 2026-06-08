namespace CareWell.Global.Constantes.Salud
{
    public abstract class TiposEventoSalud
    {
        public const int CitaMedica = (int)TiposEventoSaludEnum.CitaMedica;
        public const int Hospitalizacion = (int)TiposEventoSaludEnum.Hospitalizacion;
        public const int Medicacion = (int)TiposEventoSaludEnum.Medicacion;
        public const int Cirugia = (int)TiposEventoSaludEnum.Cirugia;
        public const int Tratamiento = (int)TiposEventoSaludEnum.Tratamiento;
        public const int Bienestar = (int)TiposEventoSaludEnum.Bienestar;
        public const int Sintoma = (int)TiposEventoSaludEnum.Sintoma;
        public const int Diagnostico = (int)TiposEventoSaludEnum.Diagnostico;
        public const int Vacuna = (int)TiposEventoSaludEnum.Vacuna;
        public const int Otro = (int)TiposEventoSaludEnum.Otro;

        private enum TiposEventoSaludEnum
        {
            CitaMedica = 1,
            Hospitalizacion = 2,
            Medicacion = 3,
            Cirugia = 4,
            Tratamiento = 5,
            Bienestar = 6,
            Sintoma = 7,
            Diagnostico = 8,
            Vacuna = 9,
            Otro = 10,
        }
    }
}
