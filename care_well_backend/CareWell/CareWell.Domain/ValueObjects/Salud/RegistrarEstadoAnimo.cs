using CareWell.Domain.General;
using CareWell.Domain.Salud;

namespace CareWell.Domain.ValueObjects.Salud
{
    public record RegistrarEstadoAnimo(
        Persona Persona,
        Persona Colaborador,
        EstadoAnimo EstadoAnimo,
        string? Observaciones
    );
}
