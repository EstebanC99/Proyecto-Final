using CareWell.DocumentIntelligence.ReconocedorTexto;
using CareWell.Domain.DomainServices.General;
using CareWell.Domain.General;
using CareWell.Domain.ValueObjects.General;
using CareWell.Global.Exceptions;
using CareWell.Global.Extensions;
using CareWell.Global.Mensajes;

namespace CareWell.BusinessService.General
{
    public class EvaluadorIdentidadPersonaBusinessService : IEvaluadorIdentidadPersonaDomainService
    {
        private IReconocedorTextoDocumentoAgent ReconocedorTextoDocumentoAgent { get; set; }

        public EvaluadorIdentidadPersonaBusinessService(IReconocedorTextoDocumentoAgent reconocedorTextoDocumentoAgent)
        {
            this.ReconocedorTextoDocumentoAgent = reconocedorTextoDocumentoAgent;
        }

        public bool EsIdentidadCorrecta(Persona persona, byte[]? imagenDocumento)
        {
            if (imagenDocumento is null || imagenDocumento.Length == default)
                throw new ValidacionDominioException(Mensajes.ImagenDocumentoRequerida);

            var agentResponse = this.ReconocedorTextoDocumentoAgent.ExtraerTexto(imagenDocumento);

            if (agentResponse is null)
                return false;

            var textoDocumentoReconocido = new TextoDocumentoReconocido(
                NumeroDocumento: agentResponse.DNI.HasValue ? agentResponse.DNI.Value.ToString() : string.Empty,
                Nombre: agentResponse.Nombre?.RemoveDiacritics() ?? string.Empty,
                Apellido: agentResponse.Apellido?.RemoveDiacritics() ?? string.Empty
            );

            persona.ValidarIdentidad(textoDocumentoReconocido);

            return persona.IdentidadValidada;
        }
    }
}
