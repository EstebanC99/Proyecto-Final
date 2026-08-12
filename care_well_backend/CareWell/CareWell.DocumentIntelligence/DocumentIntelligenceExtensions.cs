using CareWell.DocumentIntelligence.ReconocedorTexto;
using CareWell.DocumentIntelligence.ResumidorDiario;
using CareWell.Global.Enumeraciones.IA;
using CareWell.Logger;
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

            services.AddKeyedScoped<IChatClient>(ClienteVision, (serviceProvider, _) =>
                CrearChatClient(serviceProvider, opciones => opciones.ModeloVision));

            services.AddKeyedScoped<IChatClient>(ClienteTexto, (serviceProvider, _) =>
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
            var registradorLogServicioExterno = serviceProvider.GetRequiredService<IRegistradorLogServicioExterno>();

            return new GeminiChatClient(
                ResolverBaseUrl(opciones),
                opciones.ApiKey,
                seleccionarModelo(opciones),
                TimeSpan.FromSeconds(opciones.TimeoutSegundos),
                opciones.EnviarResponseSchema,
                registradorLogServicioExterno);
        }

        private static string ResolverBaseUrl(IAOptions opciones)
        {
            if (!string.IsNullOrWhiteSpace(opciones.BaseUrlPersonalizada))
                return opciones.BaseUrlPersonalizada.TrimEnd('/');

            return opciones.Proveedor switch
            {
                ProveedoresIAEnum.VertexAI => "https://aiplatform.googleapis.com/v1/publishers/google/models",
                ProveedoresIAEnum.AIStudio => "https://generativelanguage.googleapis.com/v1beta/models",
                _ => throw new InvalidOperationException($"Proveedor de IA no soportado: {opciones.Proveedor}.")
            };
        }
    }
}
