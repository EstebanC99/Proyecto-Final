using CareWell.BusinessService.Abstractions.Salud;
using CareWell.DataViews.Salud;
using CareWell.Domain.Auth;
using CareWell.Domain.DomainServices;
using CareWell.Domain.General;
using CareWell.Domain.Validadores;
using CareWell.Queries.Salud;
using CareWell.Repository.Salud;
using CareWell.Security;

namespace CareWell.BusinessService.Salud
{
    public class LineaTiempoSaludBusinessService : ILineaTiempoSaludBusinessService
    {
        private IUserContext UserContext { get; set; }
        private IEntityLoaderDomainService EntityLoaderDomainService { get; set; }
        private IValidadorPermisoAccion ValidadorPermisoAccion { get; set; }
        private ILineaTiempoSaludRepository LineaTiempoSaludRepository { get; set; }

        public LineaTiempoSaludBusinessService(IUserContext userContext,
                                               IEntityLoaderDomainService entityLoaderDomainService,
                                               IValidadorPermisoAccion validadorPermisoAccion,
                                               ILineaTiempoSaludRepository lineaTiempoSaludRepository)
        {
            this.UserContext = userContext;
            this.EntityLoaderDomainService = entityLoaderDomainService;
            this.ValidadorPermisoAccion = validadorPermisoAccion;
            this.LineaTiempoSaludRepository = lineaTiempoSaludRepository;

        }

        public List<EventoBaseDataView> ObtenerPorFechas(LineaTiempoSaludQuery query)
        {
            var usuario = this.EntityLoaderDomainService.GetByID<Usuario>(this.UserContext.UsuarioID);
            var persona = this.EntityLoaderDomainService.GetByID<Persona>(query.PersonaID);

            this.ValidadorPermisoAccion.ValidarVisualizacion(persona, usuario.Persona);

            return this.LineaTiempoSaludRepository.ObtenerPorFechas(query);
        }
    }
}
