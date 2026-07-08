namespace CareWell.Domain.Salud.AlertasBienestar
{
    public interface IDetectorAnimoBajoSostenido
    {
        AlertaBienestar? Detectar(List<PersonaEstadoAnimo> estadosAnimo, DateTime fechaReferencia);
    }
}