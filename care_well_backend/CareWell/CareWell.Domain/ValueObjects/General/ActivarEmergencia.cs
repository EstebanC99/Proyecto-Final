using CareWell.Domain.General;

namespace CareWell.Domain.ValueObjects.General
{
    public record ActivarEmergencia
    (
        Persona Persona,
        Persona Activador,
        string? Descripcion
    );
}
