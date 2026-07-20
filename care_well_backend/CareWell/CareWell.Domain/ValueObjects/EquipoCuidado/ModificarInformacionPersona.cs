using CareWell.Domain.Auth;
using CareWell.Domain.ValueObjects.General;

namespace CareWell.Domain.ValueObjects.EquipoCuidado
{
    public record ModificarInformacionPersona(
        string Nombre,
        string Apellido,
        string Documento,
        DateTime FechaNacimiento,
        string? Telefono,
        byte[]? Imagen,
        string? Email,
        Usuario UsuarioModificador
        )
        : CrearModificarPersona(
        Nombre,
        Apellido,
        Documento,
        FechaNacimiento,
        Telefono,
        Imagen,
        Email);
}
