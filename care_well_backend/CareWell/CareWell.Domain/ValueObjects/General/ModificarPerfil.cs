namespace CareWell.Domain.ValueObjects.General
{
    public record ModificarPerfil(
        string Nombre,
        string Apellido,
        string Documento,
        DateTime FechaNacimiento,
        string? Telefono,
        byte[]? Imagen
    );
}
