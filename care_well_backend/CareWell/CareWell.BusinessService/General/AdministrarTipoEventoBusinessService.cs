using CareWell.BusinessService.Abstractions.General;
using CareWell.DataViews.General;
using CareWell.Repository;
using CareWell.Repository.General;

namespace CareWell.BusinessService.General
{
    public class AdministrarTipoEventoBusinessService : BusinessService, IAdministrarTipoEventoBusinessService
    {
        private ITipoEventoRepository TipoEventoRepository { get; set; }

        public AdministrarTipoEventoBusinessService(IUnitOfWork unitOfWork,
                                                    ITipoEventoRepository tipoEventoRepository)
            : base(unitOfWork)
        {
            this.TipoEventoRepository = tipoEventoRepository;
        }

        public List<TipoEventoDataView> ObtenerTodos()
        {
            return this.TipoEventoRepository.ObtenerTodos();
        }
    }
}
