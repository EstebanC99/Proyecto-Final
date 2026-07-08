using CareWell.Domain.Salud;

namespace CareWell.Repository.Salud
{
    public interface IAlertaBienestarRepository : IRepository
    {
        List<PersonaEstadoAnimo> GetEstadosAnimo(int personaID, DateTime fechaDesde);
        List<HabitoVida> GetHabitosActivos(int personaID);
    }
}