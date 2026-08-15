using CareWell.Domain.General;

namespace CareWell.Domain.ValueObjects.General
{
    public record GenerarResumenDiario
    (
        Persona Persona,
        string Contenido,
        DateTime FechaHoraGeneracion
    );
}
