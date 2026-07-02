using CareWell.Global.Enumeraciones.Agenda;

namespace CareWell.Domain.ValueObjects.Agenda
{
    public record DefinirRecurrenciaEventoAgenda
    (
        FrecuenciaRecurrenciaEnum FrecuenciaRecurrencia,
        int Intervalo,
        DateTime? FechaFin
    );
}
