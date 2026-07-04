using CareWell.Domain.General;
using CareWell.Domain.Salud;

namespace CareWell.Domain.ValueObjects.Salud
{
    public record ModificarHabitoVida(
        Persona Colaborador,
        TipoHabitoVida TipoHabito,
        string Descripcion
    );
}
