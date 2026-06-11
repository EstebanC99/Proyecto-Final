using CareWell.Repository.Auth;
using CareWell.Repository.General;
using Microsoft.Extensions.DependencyInjection;

namespace CareWell.Repository
{
    public static class RepositoryServiceExtensions
    {
        public static IServiceCollection AddRepositories(this IServiceCollection services)
        {
            services.AddScoped<IUnitOfWork, UnitOfWork>();
            services.AddScoped<IEntityLoaderRepository, EntityLoaderRepository>();

            #region Business Repos

            services.AddScoped<IPersonaRepository, PersonaRepository>();
            services.AddScoped<IUsuarioRepository, UsuarioRepository>();

            #endregion

            return services;
        }
    }
}
