using CareWell.Domain.ValueObjects.Agenda;

namespace CareWell.Domain.DomainServices.Agenda
{
    public interface IExpansorRecurrenciaDomainService
    {
        string ConstruirRegla(DefinirRecurrenciaEventoAgenda definirRecurrencia, DateTime fechaHoraInicio);
        bool EsReglaValida(string regla);
        List<DateTime> ExpandirOcurrencias(string regla, DateTime inicioBase, string? excepciones, DateTime desde, DateTime hasta);
    }
}
