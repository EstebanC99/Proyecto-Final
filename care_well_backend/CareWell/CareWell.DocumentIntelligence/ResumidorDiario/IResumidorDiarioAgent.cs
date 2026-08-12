namespace CareWell.DocumentIntelligence.ResumidorDiario
{
    public interface IResumidorDiarioAgent
    {
        Task<ResumidorDiarioAgentResponse> ArmarResumen(ResumidorTextoAgentRequest request, CancellationToken cancellationToken);
    }
}