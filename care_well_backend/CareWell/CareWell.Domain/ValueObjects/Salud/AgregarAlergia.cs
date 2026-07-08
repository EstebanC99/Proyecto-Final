namespace CareWell.Domain.ValueObjects.Salud
{
    public record AgregarAlergia(
        int ID,
        string Nombre,
        string Reaccion,
        string? Medicamento
    );
}
