using CareWell.Commands.Emergencias;
using CareWell.DataViews.Emergencias;
using CareWell.Queries.Emergencias;

namespace CareWell.BusinessService.Abstractions.Emergencias
{
    public interface IActivarEmergenciaBusinessService
    {
        Task Activar(ActivarEmergenciaCommand command, CancellationToken cancellationToken);
        List<EmergenciaDataView> Obtener(ObtenerEmergenciasQuery query);
    }
}
