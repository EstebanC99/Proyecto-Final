namespace CareWell.Global.Constantes.Agenda
{
    public abstract class TiposEventoAgenda
    {
        public const int CitaMedica = (int)TiposEventoAgendaEnum.CitaMedica;
        public const int Medicacion = (int)TiposEventoAgendaEnum.Medicacion;
        public const int Rehabilitacion = (int)TiposEventoAgendaEnum.Rehabilitacion;
        public const int Control = (int)TiposEventoAgendaEnum.Control;
        public const int Otro = (int)TiposEventoAgendaEnum.Otro;

        private enum TiposEventoAgendaEnum
        {
            CitaMedica = 1,
            Medicacion = 2,
            Rehabilitacion = 3,
            Control = 4,
            Otro = 5
        }
    }
}
