namespace CareWell.Domain.ValueObjects.General
{
    public record CrearModificarPersona(
        string Nombre,
        string Apellido,
        string Documento,
        DateTime FechaNacimiento,
        string? Email,
        string? Telefono
    );
}
