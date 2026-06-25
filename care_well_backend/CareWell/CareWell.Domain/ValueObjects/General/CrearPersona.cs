namespace CareWell.Domain.ValueObjects.General
{
    public record CrearPersona(
        string Nombre,
        string Apellido,
        string Documento,
        DateTime FechaNacimiento,
        string? Email,
        string? Telefono
    );
}
