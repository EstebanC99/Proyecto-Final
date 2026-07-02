using CareWell.Domain.General;

namespace CareWell.Domain.ValueObjects.Agenda
{
    public record CrearEventoAgenda
    (
        Persona Persona,
        Persona Creador,
        string Titulo,
        string? Descripcion,
        TipoEvento Tipo,
        DateTime FechaHoraInicio,
        TimeSpan Duracion,
        DefinirRecurrenciaEventoAgenda? Recurrencia,
        bool GenerarEventoSalud,
        int? MinutosAnticipacionRecordatorio
    );

}
