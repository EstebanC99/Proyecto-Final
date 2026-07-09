using CareWell.Domain.Auth;
using CareWell.Domain.ValueObjects.General;

namespace CareWell.Domain.ValueObjects.EquipoCuidado
{
    public record ModificarInformacionPersona(
        string Nombre,
        string Apellido,
        string Documento,
        DateTime FechaNacimiento,
        string? Email,
        string? Telefono,
        string? Imagen,
        Usuario UsuarioModificador
        )
        : CrearModificarPersona(
        Nombre,
        Apellido,
        Documento,
        FechaNacimiento,
        Email,
        Telefono,
        Imagen);
}
