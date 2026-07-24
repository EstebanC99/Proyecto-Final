using CareWell.DocumentIntelligence.ReconocedorTexto;
using Microsoft.Extensions.AI;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Options;
using OllamaSharp;

namespace CareWell.DocumentIntelligence
{
    public static class DocumentIntelligenceExtensions
    {
        public static IServiceCollection AddDocumentIntelligences(this IServiceCollection services)
        {
            #region Cliente Ollama

            services.AddSingleton<IChatClient>(serviceProvider =>
            {
                var opciones = serviceProvider
                    .GetRequiredService<IOptions<ReconocedorTextoDocumentoOptions>>()
                    .Value;

                var httpClient = new HttpClient
                {
                    BaseAddress = new Uri(opciones.OllamaUrl),
                    Timeout = TimeSpan.FromSeconds(opciones.TimeoutSegundos)
                };

                return new OllamaApiClient(httpClient, opciones.Modelo);
            });

            #endregion

            #region Reconocedor de Texto

            services.AddScoped<IReconocedorTextoDocumentoAgent, ReconocedorTextoDocumentoAgent>();

            #endregion

            return services;
        }
    }
}
