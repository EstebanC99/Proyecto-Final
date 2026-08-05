using CareWell.DataViews.Emergencias;
using CareWell.Domain.Auth;
using CareWell.Domain.Emergencias;
using CareWell.Queries.Emergencias;

namespace CareWell.Repository.Emergencias
{
    public interface IEmergenciaRepository : IRepository<Emergencia>
    {
        List<EmergenciaDataView> ObtenerPorPersona(ObtenerEmergenciasQuery query);

        List<Usuario> GetUsuariosColaboradoresActivos(Emergencia emergencia);
    }
}