using CareWell.BusinessService.Abstractions.Agenda;
using CareWell.BusinessService.Abstractions.Auth;
using CareWell.BusinessService.Abstractions.EquipoCuidado;
using CareWell.BusinessService.Abstractions.General;
using CareWell.BusinessService.Abstractions.Salud;
using CareWell.BusinessService.Agenda;
using CareWell.BusinessService.Auth;
using CareWell.BusinessService.EquipoCuidado;
using CareWell.BusinessService.General;
using CareWell.BusinessService.Salud;
using CareWell.Domain.DomainServices;
using CareWell.Domain.DomainServices.Agenda;
using CareWell.Domain.DomainServices.Auth;
using CareWell.Domain.DomainServices.General;
using CareWell.Domain.DomainServices.Salud;
using CareWell.Domain.Factories;
using CareWell.Domain.Salud.AlertasBienestar;
using CareWell.Domain.Validadores;
using Microsoft.Extensions.DependencyInjection;

namespace CareWell.BusinessService
{
    public static class BusinessServiceExtensions
    {
        public static IServiceCollection AddBusinessServices(this IServiceCollection services)
        {
            services.AddScoped<IBaseFactory, BaseFactory>();
            services.AddScoped<IEntityLoaderDomainService, EntityLoaderBusinessService>();

            #region Autorizacion

            services.AddScoped<IPasswordHasherDomainService, PasswordHasherBusinessService>();
            services.AddScoped<ITokenAutorizacionBusinessService, TokenAutorizacionBusinessService>();
            services.AddScoped<ILoginBusinessService, LoginBusinessService>();
            services.AddScoped<IRefrescarTokenBusinessService, RefrescarTokenBusinessService>();

            #endregion

            #region Business Services

            services.AddScoped<IAdministrarEquipoCuidadoBusinessService, AdministrarEquipoCuidadoBusinessService>();
            services.AddScoped<IAdministrarEventoAgendaBusinessService, AdministrarEventoAgendaBusinessService>();
            services.AddScoped<IAdministrarEventoSaludBusinessService, AdministrarEventoSaludBusinessService>();
            services.AddScoped<IAdministrarFichaSaludBusinessService, AdministrarFichaSaludBusinessService>();
            services.AddScoped<IAdministrarHabitoVidaBusinessService, AdministrarHabitoVidaBusinessService>();
            services.AddScoped<IAdministrarPersonaBusinessService, AdministrarPersonaBusinessService>();
            services.AddScoped<IAdministrarPersonaEstadoAnimoBusinessService, AdministrarPersonaEstadoAnimoBusinessService>();
            services.AddScoped<IAdministrarPersonasCargoBusinessService, AdministrarPersonasCargoBusinessService>();
            services.AddScoped<IAdministrarTipoEventoBusinessService, AdministrarTipoEventoBusinessService>();
            services.AddScoped<IAdministrarTipoHabitoVidaBusinessService, AdministrarTipoHabitoVidaBusinessService>();
            services.AddScoped<IAlertaBienestarBusinessService, AlertaBienestarBusinessService>();
            services.AddScoped<ICrearCredencialesBusinessService, CrearCredencialesBusinessService>();
            services.AddScoped<ICrearCuentaBusinessService, CrearCuentaBusinessService>();
            services.AddScoped<IEliminarCuentaBusinessService, EliminarCuentaBusinessService>();
            services.AddScoped<IEnvioEmailBusinessService, EnvioEmailBusinessService>();
            services.AddScoped<IGenerarEventoSaludBusinessService, GenerarEventoSaludBusinessService>();
            services.AddScoped<ILineaTiempoSaludBusinessService, LineaTiempoSaludBusinessService>();
            services.AddScoped<IRecuperacionContrasenaBusinessService, RecuperacionContrasenaBusinessService>();
            services.AddScoped<IVerificacionEmailBusinessService, VerificacionEmailBusinessService>();

            #endregion

            #region Domain Services

            services.AddScoped<IDetectorAlertasBienestarDomainService, DetectorAlertasBienestarBusinessService>();
            services.AddScoped<IEvaluadorIdentidadPersonaDomainService, EvaluadorIdentidadPersonaBusinessService>();
            services.AddScoped<IExpansorRecurrenciaDomainService, ExpansorRecurrenciaBusinessService>();
            services.AddScoped<IGeneradorCodigoOtpDomainService, GeneradorCodigoOtpBusinessService>();
            services.AddScoped<IGestorCodigoVerificacionDomainService, GestorCodigoVerificacionBusinessService>();
            services.AddScoped<ISerializadorFechasExceptuadasDomainService, SerializadorFechasExceptuadasBusinessService>();

            #endregion

            #region Domain

            services.AddScoped<IDetectorAlertaHabito, DetectorAlertaHabito>();
            services.AddScoped<IDetectorAnimoBajoSostenido, DetectorAnimoBajoSostenido>();
            services.AddScoped<IDetectorDeterioroAnimo, DetectorDeterioroAnimo>();
            services.AddScoped<IValidadorLimiteEnvioCodigo, ValidadorLimiteEnvioCodigo>();
            services.AddScoped<IValidadorPermisoAccion, ValidadorPermisoAccion>();
            services.AddScoped<IValidarExistenciaAsignacionCuidado, ValidarExistenciaAsignacionCuidado>();

            #endregion

            return services;
        }
    }
}
