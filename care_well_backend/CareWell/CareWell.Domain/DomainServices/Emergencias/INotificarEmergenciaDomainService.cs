using CareWell.Domain.Emergencias;

namespace CareWell.Domain.DomainServices.Emergencias
{
    public interface INotificarEmergenciaDomainService
    {
        Task Notificar(Emergencia emergencia, CancellationToken cancellationToken);
    }
}
