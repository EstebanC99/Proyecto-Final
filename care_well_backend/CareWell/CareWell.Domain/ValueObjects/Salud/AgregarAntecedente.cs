namespace CareWell.Domain.ValueObjects.Salud
{
    public record AgregarAntecedente(
        int ID,
        string Nombre,
        string Descripcion,
        string VinculoFamiliar
    );
}
