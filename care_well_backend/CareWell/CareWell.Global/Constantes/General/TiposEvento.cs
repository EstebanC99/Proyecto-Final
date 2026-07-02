namespace CareWell.Global.Constantes.General
{
    public abstract class TiposEvento
    {
        public const int CitaMedica = (int)TiposEventoEnum.CitaMedica;
        public const int Medicacion = (int)TiposEventoEnum.Medicacion;
        public const int Rehabilitacion = (int)TiposEventoEnum.Rehabilitacion;
        public const int Control = (int)TiposEventoEnum.Control;
        public const int Hospitalizacion = (int)TiposEventoEnum.Hospitalizacion;
        public const int Cirugia = (int)TiposEventoEnum.Cirugia;
        public const int Tratamiento = (int)TiposEventoEnum.Tratamiento;
        public const int Bienestar = (int)TiposEventoEnum.Bienestar;
        public const int Sintoma = (int)TiposEventoEnum.Sintoma;
        public const int Diagnostico = (int)TiposEventoEnum.Diagnostico;
        public const int Vacuna = (int)TiposEventoEnum.Vacuna;
        public const int ActividadFisica = (int)TiposEventoEnum.ActividadFisica;
        public const int Otro = (int)TiposEventoEnum.Otro;

        private enum TiposEventoEnum
        {
            CitaMedica = 1,
            Medicacion = 2,
            Rehabilitacion = 3,
            Control = 4,
            Hospitalizacion = 5,
            Cirugia = 6,
            Tratamiento = 7,
            Bienestar = 8,
            Sintoma = 9,
            Diagnostico = 10,
            Vacuna = 11,
            ActividadFisica = 12,
            Otro = 13
        }
    }
}
