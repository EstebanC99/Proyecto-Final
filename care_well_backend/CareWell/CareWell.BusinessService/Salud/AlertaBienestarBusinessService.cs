using CareWell.BusinessService.Abstractions.Salud;
using CareWell.DataViews.Salud;
using CareWell.Domain.Auth;
using CareWell.Domain.DomainServices;
using CareWell.Domain.DomainServices.Salud;
using CareWell.Domain.General;
using CareWell.Domain.Salud.AlertasBienestar;
using CareWell.Domain.Validadores;
using CareWell.Domain.ValueObjects.Salud;
using CareWell.Global.Constantes.Salud;
using CareWell.Queries.Salud;
using CareWell.Repository.Salud;
using CareWell.Security;

namespace CareWell.BusinessService.Salud
{
    public class AlertaBienestarBusinessService : IAlertaBienestarBusinessService
    {
        private IUserContext UserContext { get; set; }
        private IEntityLoaderDomainService EntityLoaderDomainService { get; set; }
        private IValidadorPermisoAccion ValidadorPermisoAccion { get; set; }
        private IDetectorAlertasBienestarDomainService DetectorAlertasBienestarDomainService { get; set; }
        private IAlertaBienestarRepository AlertaBienestarRepository { get; set; }

        public AlertaBienestarBusinessService(IUserContext userContext,
                                              IEntityLoaderDomainService entityLoaderDomainService,
                                              IValidadorPermisoAccion validadorPermisoAccion,
                                              IDetectorAlertasBienestarDomainService detectorAlertasBienestarDomainService,
                                              IAlertaBienestarRepository alertasBienestarRepository)
        {
            this.UserContext = userContext;
            this.EntityLoaderDomainService = entityLoaderDomainService;
            this.ValidadorPermisoAccion = validadorPermisoAccion;
            this.DetectorAlertasBienestarDomainService = detectorAlertasBienestarDomainService;
            this.AlertaBienestarRepository = alertasBienestarRepository;
        }

        public List<AlertaBienestarDataView> Obtener(AlertaBienestarQuery query)
        {
            var usuario = this.EntityLoaderDomainService.GetByID<Usuario>(this.UserContext.UsuarioID);
            var persona = this.EntityLoaderDomainService.GetByID<Persona>(query.PersonaID);

            this.ValidadorPermisoAccion.ValidarVisualizacion(persona, usuario.Persona);

            var fechaReferencia = DateTime.Now;
            var fechaDesde = fechaReferencia.AddDays(-(ParametrosDeteccionBienestar.DiasVentanaReciente + ParametrosDeteccionBienestar.DiasVentanaBase));

            var estadosAnimo = this.AlertaBienestarRepository.GetEstadosAnimo(query.PersonaID, fechaDesde);
            var habitosVida = this.AlertaBienestarRepository.GetHabitosActivos(query.PersonaID);

            var entrada = new DetectarAlertaBienestar(
                EstadosAnimo: estadosAnimo, 
                HabitosVida: habitosVida, 
                FechaReferencia: fechaReferencia
            );

            var alertas = this.DetectorAlertasBienestarDomainService.Detectar(entrada);

            return alertas.Select(MapToDataView).ToList();
        }

        #region Metodos Privados

        private static AlertaBienestarDataView MapToDataView(AlertaBienestar alerta)
        {
            return new AlertaBienestarDataView
            {
                Tipo = alerta.Tipo,
                Severidad = alerta.Severidad,
                Categoria = alerta.Categoria,
                Mensaje = alerta.Mensaje,
                FechaDeteccion = alerta.FechaDeteccion,
                HabitoVidaID = alerta.HabitoVida?.ID
            };
        }

        #endregion
    }
}
