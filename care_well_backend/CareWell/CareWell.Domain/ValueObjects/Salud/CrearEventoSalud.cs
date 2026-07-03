using CareWell.Domain.General;

namespace CareWell.Domain.ValueObjects.Salud
{
    public record CrearEventoSalud(
        Persona Persona,
        Persona Colaborador,
        TipoEvento Tipo,
        DateTime FechaHora,
        string Descripcion
    );
}
