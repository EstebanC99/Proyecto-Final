using CareWell.Domain.General;

namespace CareWell.Domain.ValueObjects.Agenda
{
    public record ModificarEventoAgenda
    (
        Persona Solicitante,
        string Titulo,
        string? Descripcion,
        TipoEvento Tipo,
        DateTime FechaHoraInicio,
        TimeSpan Duracion,
        DefinirRecurrenciaEventoAgenda? Recurrencia,
        bool GenerarEventoSalud,
        int? MinutosAnticipacionRecordatorio
    ) :
    CrearEventoAgenda
    (
        null,
        Solicitante,
        Titulo,
        Descripcion,
        Tipo,
        FechaHoraInicio,
        Duracion,
        Recurrencia,
        GenerarEventoSalud,
        MinutosAnticipacionRecordatorio
    );
}
