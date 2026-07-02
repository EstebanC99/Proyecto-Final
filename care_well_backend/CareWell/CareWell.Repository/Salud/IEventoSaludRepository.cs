using CareWell.Domain.Salud;

namespace CareWell.Repository.Salud
{
    public interface IEventoSaludRepository : IRepository<EventoSalud>
    {
        bool ExistePorOrigen(int eventoAgendaID, DateTime fechaOcurrencia);
    }
}