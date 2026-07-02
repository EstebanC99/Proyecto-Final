using CareWell.BusinessService.Abstractions.Agenda;
using CareWell.BusinessService.Abstractions.Auth;
using CareWell.BusinessService.Abstractions.EquipoCuidado;
using CareWell.BusinessService.Abstractions.Salud;
using CareWell.BusinessService.Agenda;
using CareWell.BusinessService.Auth;
using CareWell.BusinessService.EquipoCuidado;
using CareWell.BusinessService.Salud;
using CareWell.Domain.DomainServices;
using CareWell.Domain.DomainServices.Agenda;
using CareWell.Domain.DomainServices.Auth;
using CareWell.Domain.Factories;
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

            services.AddScoped<ICrearCuentaBusinessService, CrearCuentaBusinessService>();
            services.AddScoped<IAdministrarPersonasCargoBusinessService, AdministrarPersonasCargoBusinessService>();
            services.AddScoped<IAdministrarEquipoCuidadoBusinessService, AdministrarEquipoCuidadoBusinessService>();
            services.AddScoped<IGenerarEventoSaludBusinessService, GenerarEventoSaludBusinessService>();
            services.AddScoped<IAdministrarEventoAgendaBusinessService, AdministrarEventoAgendaBusinessService>();

            #endregion

            #region Domain

            services.AddScoped<IValidadorPermisoAccion, ValidadorPermisoAccion>();
            services.AddScoped<IValidarExistenciaAsignacionCuidado, ValidarExistenciaAsignacionCuidado>();
            services.AddScoped<ISerializadorFechasExceptuadasDomainService, SerializadorFechasExceptuadasBusinessService>();
            services.AddScoped<IExpansorRecurrenciaDomainService, ExpansorRecurrenciaBusinessService>();

            #endregion

            return services;
        }
    }
}
