using CareWell.BusinessService.Abstractions.Salud;
using CareWell.DataViews;
using CareWell.Repository;
using CareWell.Repository.Salud;

namespace CareWell.BusinessService.Salud
{
    public class AdministrarTipoHabitoVidaBusinessService : BusinessService, IAdministrarTipoHabitoVidaBusinessService
    {
        private ITipoHabitoVidaRepository TipoHabitoVidaRepository { get; set; }

        public AdministrarTipoHabitoVidaBusinessService(IUnitOfWork unitOfWork,
                                                        ITipoHabitoVidaRepository tipoHabitoVidaRepository)
            : base(unitOfWork)
        {
            this.TipoHabitoVidaRepository = tipoHabitoVidaRepository;
        }

        public List<BaseEntityDataView> ObtenerTodos()
        {
            return this.TipoHabitoVidaRepository.ObtenerTodos();
        }
    }

}
