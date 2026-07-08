namespace CareWell.Domain.Salud.AlertasBienestar
{
    public interface IDetectorAlertaHabito
    {
        AlertaBienestar? Detectar(HabitoVida habitoVida, DateTime fechaReferencia, DateTime inicioReciente, DateTime inicioBase);
    }
}