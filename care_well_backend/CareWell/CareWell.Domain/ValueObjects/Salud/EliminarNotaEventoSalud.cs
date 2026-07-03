using CareWell.Domain.General;

namespace CareWell.Domain.ValueObjects.Salud
{
    public record EliminarNotaEventoSalud(
        Persona Colaborador,
        int NotaID
    );
}
