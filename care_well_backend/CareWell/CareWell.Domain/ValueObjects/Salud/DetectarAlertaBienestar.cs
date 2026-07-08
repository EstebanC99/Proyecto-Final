using CareWell.Domain.Salud;

namespace CareWell.Domain.ValueObjects.Salud
{
    public record DetectarAlertaBienestar(
        List<PersonaEstadoAnimo> EstadosAnimo,
        List<HabitoVida> HabitosVida,
        DateTime FechaReferencia
    );
}
