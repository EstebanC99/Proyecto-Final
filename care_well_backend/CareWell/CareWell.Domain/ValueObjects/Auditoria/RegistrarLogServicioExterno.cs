namespace CareWell.Domain.ValueObjects.Auditoria
{
    public record RegistrarLogServicioExterno
    (
        string NombreServicioExterno,
        string Request,
        string Response
    );
}
