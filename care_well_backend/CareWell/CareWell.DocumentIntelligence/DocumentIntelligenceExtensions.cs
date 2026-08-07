using CareWell.DocumentIntelligence.ReconocedorTexto;
using CareWell.DocumentIntelligence.ResumidorDiario;
using Microsoft.Extensions.AI;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Options;

namespace CareWell.DocumentIntelligence
{
    public static class DocumentIntelligenceExtensions
    {
        public const string ClienteVision = "vision";
        public const string ClienteTexto = "texto";

        public static IServiceCollection AddDocumentIntelligences(this IServiceCollection services)
        {
            #region Clientes de IA (Gemini, API nativa)

            services.AddKeyedSingleton<IChatClient>(ClienteVision, (serviceProvider, _) =>
                CrearChatClient(serviceProvider, opciones => opciones.ModeloVision));

            services.AddKeyedSingleton<IChatClient>(ClienteTexto, (serviceProvider, _) =>
                CrearChatClient(serviceProvider, opciones => opciones.ModeloTexto));

            #endregion

            #region Agentes de IA

            services.AddScoped<IResumidorDiarioAgent, ResumidorDiarioAgent>();
            services.AddScoped<IReconocedorTextoDocumentoAgent, ReconocedorTextoDocumentoAgent>();

            #endregion

            return services;
        }

        private static IChatClient CrearChatClient(IServiceProvider serviceProvider, Func<IAOptions, string> seleccionarModelo)
        {
            var opciones = serviceProvider.GetRequiredService<IOptions<IAOptions>>().Value;

            return new GeminiChatClient(
                opciones.ApiKey,
                seleccionarModelo(opciones),
                TimeSpan.FromSeconds(opciones.TimeoutSegundos));
        }
    }
}
