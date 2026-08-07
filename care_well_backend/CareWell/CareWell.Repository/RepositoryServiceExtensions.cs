using CareWell.Repository.Agenda;
using CareWell.Repository.Auditoria;
using CareWell.Repository.Auth;
using CareWell.Repository.Emergencias;
using CareWell.Repository.EquipoCuidado;
using CareWell.Repository.General;
using CareWell.Repository.Salud;
using Microsoft.Extensions.DependencyInjection;

namespace CareWell.Repository
{
    public static class RepositoryServiceExtensions
    {
        public static IServiceCollection AddRepositories(this IServiceCollection services)
        {
            services.AddScoped<IUnitOfWork, UnitOfWork>();
            services.AddScoped<IEntityLoaderRepository, EntityLoaderRepository>();

            #region Autorizacion

            services.AddScoped<IRefreshTokenRepository, RefreshTokenRepository>();

            #endregion

            #region Business Repos

            services.AddScoped<IAlertaBienestarRepository, AlertaBienestarRepository>();
            services.AddScoped<IAsignacionCuidadoRepository, AsignacionCuidadoRepository>();
            services.AddScoped<ICodigoVerificacionRepository, CodigoVerificacionRepository>();
            services.AddScoped<IDispositivoUsuarioRepository, DispositivoUsuarioRepository>();
            services.AddScoped<IEmergenciaRepository, EmergenciaRepository>();
            services.AddScoped<IEventoAgendaRepository, EventoAgendaRepository>();
            services.AddScoped<IEventoSaludRepository, EventoSaludRepository>();
            services.AddScoped<IFichaSaludRepository, FichaSaludRepository>();
            services.AddScoped<IHabitoVidaRepository, HabitoVidaRepository>();
            services.AddScoped<ILineaTiempoSaludRepository, LineaTiempoSaludRepository>();
            services.AddScoped<IPersonaEstadoAnimoRepository, PersonaEstadoAnimoRepository>();
            services.AddScoped<IPersonaRepository, PersonaRepository>();
            services.AddScoped<ITipoEventoRepository, TipoEventoRepository>();
            services.AddScoped<ITipoHabitoVidaRepository, TipoHabitoVidaRepository>();
            services.AddScoped<IUsuarioRepository, UsuarioRepository>();

            #endregion

            #region Logs

            services.AddScoped<ILogExcepcionRepository, LogExcepcionRepository>();
            services.AddScoped<ILogServicioExternoRepository, LogServicioExternoRepository>();
            services.AddScoped<ILogUnitOfWork, LogUnitOfWork>();

            #endregion

            return services;
        }
    }
}
