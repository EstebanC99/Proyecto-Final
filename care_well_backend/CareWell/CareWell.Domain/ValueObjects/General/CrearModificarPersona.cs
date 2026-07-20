namespace CareWell.Domain.ValueObjects.General
{
    public record CrearModificarPersona(
        string Nombre,
        string Apellido,
        string Documento,
        DateTime FechaNacimiento,
        string? Telefono,
        byte[]? Imagen,
        string? Email
    ) :
    ModificarPerfil(
        Nombre: Nombre,
        Apellido: Apellido,
        Documento: Documento,
        FechaNacimiento: FechaNacimiento,
        Telefono: Telefono,
        Imagen: Imagen
    );
}
