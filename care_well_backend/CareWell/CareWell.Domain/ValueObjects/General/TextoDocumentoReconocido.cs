namespace CareWell.Domain.ValueObjects.General
{
    public record TextoDocumentoReconocido(
        string NumeroDocumento,
        string Nombre,
        string Apellido
    );
}
