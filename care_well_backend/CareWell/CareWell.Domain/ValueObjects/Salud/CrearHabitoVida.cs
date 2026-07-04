using CareWell.Domain.General;
using CareWell.Domain.Salud;

namespace CareWell.Domain.ValueObjects.Salud
{
    public record CrearHabitoVida(
        Persona Persona,
        Persona Colaborador,
        TipoHabitoVida TipoHabito,
        string Descripcion
    );
}
