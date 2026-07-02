namespace CareWell.Domain.DomainServices.Agenda
{
    public interface ISerializadorFechasExceptuadasDomainService
    {
        string? SerializarFechasExceptuadas(List<DateTime> fechas);
        List<DateTime> DeserializarFechasExceptuadas(string? fechasSerializadas);
    }
}
