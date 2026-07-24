namespace CareWell.DocumentIntelligence.ReconocedorTexto
{
    public interface IReconocedorTextoDocumentoAgent
    {
        ReconocedorTextoDocumentoAgentResponse? ExtraerTexto(byte[] imagenDocumento);
    }
}
