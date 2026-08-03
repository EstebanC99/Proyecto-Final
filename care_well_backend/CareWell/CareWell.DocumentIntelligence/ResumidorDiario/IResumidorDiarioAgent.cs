namespace CareWell.DocumentIntelligence.ResumidorDiario
{
    public interface IResumidorDiarioAgent
    {
        Task<string?> ArmarResumen(ResumidorTextoAgentRequest request, CancellationToken cancellationToken);
    }
}