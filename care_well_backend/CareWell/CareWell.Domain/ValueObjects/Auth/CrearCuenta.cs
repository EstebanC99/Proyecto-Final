namespace CareWell.Domain.ValueObjects.Auth
{
    public record CrearCuenta(
        string Nombre,
        string Apellido,
        string Documento,
        DateTime FechaNacimiento,
        string Email,
        string Telefono
    );
}
