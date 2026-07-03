using CareWell.Domain.General;

namespace CareWell.Domain.ValueObjects.Salud
{
    public record ModificarNotaEventoSalud(
        Persona Colaborador,
        int NotaID,
        string Contenido
    );
}
