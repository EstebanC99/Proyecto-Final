using CareWell.DataViews.EquipoCuidado;
using CareWell.Domain.EquipoCuidado;
using CareWell.Domain.General;

namespace CareWell.Repository.EquipoCuidado
{
    public interface IAsignacionCuidadoRepository : IRepository<AsignacionCuidado>
    {
        List<AsignacionCuidadoDataView> ObtenerAsignacionesPorUsuario(int usuarioID);
        List<AsignacionCuidadoDataView> ObtenerAsignacionesPorPersonaCuidada(int personaCuidadaID);

        AsignacionCuidado GetInactiveByColaborador(Persona personaCuidada, Persona colaborador);
    }
}