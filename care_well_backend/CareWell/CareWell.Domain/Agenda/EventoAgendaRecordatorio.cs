namespace CareWell.Domain.Agenda
{
    public class EventoAgendaRecordatorio : BaseEntity
    {
        public virtual EventoAgenda EventoAgenda { get; private set; }

        public virtual DateTime FechaHoraEnvio { get; private set; }

        public virtual bool Enviado { get; private set; }
    }
}
