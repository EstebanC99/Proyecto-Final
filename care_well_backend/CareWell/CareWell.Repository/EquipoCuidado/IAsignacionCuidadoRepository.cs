using CareWell.DataViews.EquipoCuidado;
using CareWell.Domain.EquipoCuidado;

namespace CareWell.Repository.EquipoCuidado
{
    public interface IAsignacionCuidadoRepository : IRepository<AsignacionCuidado>
    {
        List<AsignacionCuidadoDataView> ObtenerAsignacionesPorUsuario(int usuarioID);
    }
}