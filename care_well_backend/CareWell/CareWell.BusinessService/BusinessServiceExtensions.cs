using CareWell.BusinessService.Abstractions.Auth;
using CareWell.BusinessService.Auth;
using CareWell.Domain.DomainServices;
using CareWell.Domain.DomainServices.Auth;
using CareWell.Domain.Factories;
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

            #endregion

            #region Business Services

            services.AddScoped<ICrearCuentaBusinessService, CrearCuentaBusinessService>();

            #endregion

            return services;
        }
    }
}
