namespace CareWell.Domain.Salud.AlertasBienestar
{
    public interface IDetectorDeterioroAnimo
    {
        AlertaBienestar? Detectar(List<PersonaEstadoAnimo> estadosAnimo, DateTime fechaReferencia, DateTime inicioReciente, DateTime inicioBase);
    }
}