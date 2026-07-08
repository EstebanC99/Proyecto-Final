namespace CareWell.Domain.ValueObjects.Salud
{
    public record AgregarEnfermedad(
        int ID,
        string Nombre,
        bool Vigente,
        string? Observacion
    );
}
