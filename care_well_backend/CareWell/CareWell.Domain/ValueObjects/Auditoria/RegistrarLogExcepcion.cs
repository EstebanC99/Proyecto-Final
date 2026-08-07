namespace CareWell.Domain.ValueObjects.Auditoria
{
    public record RegistrarLogExcepcion
    (
        string Tipo,
        bool Controlada,
        string Mensaje,
        string StackTrace,
        string Ruta,
        string Verbo,
        string TraceIdentifier,
        int? UsuarioID
    );
}
