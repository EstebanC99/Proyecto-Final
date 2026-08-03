using CareWell.Domain.General;

namespace CareWell.Domain.DomainServices.General
{
    public interface IArmarResumenDiarioDomainService
    {
        Task<string?> Armar(Persona personaCuidada, CancellationToken cancellationToken);
    }
}
