using CareWell.Domain.General;

namespace CareWell.Domain.ValueObjects.Salud
{
    public record CrearNotaEventoSalud(
        Persona Autor,
        string Contenido
    );
}
