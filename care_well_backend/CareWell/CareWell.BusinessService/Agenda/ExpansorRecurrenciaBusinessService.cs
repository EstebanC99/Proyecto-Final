using CareWell.BusinessService.Helpers;
using CareWell.Domain.DomainServices.Agenda;
using CareWell.Domain.ValueObjects.Agenda;
using CareWell.Global.Constantes.Agenda;
using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;
using Ical.Net;
using Ical.Net.CalendarComponents;
using Ical.Net.DataTypes;
using Ical.Net.Serialization.DataTypes;

namespace CareWell.BusinessService.Agenda
{
    public class ExpansorRecurrenciaBusinessService : IExpansorRecurrenciaDomainService
    {
        private ISerializadorFechasExceptuadasDomainService SerializadorFechasExceptuadasDomainService { get; set; }

        public ExpansorRecurrenciaBusinessService(ISerializadorFechasExceptuadasDomainService serializadorFechasExceptuadasDomainService)
        {
            this.SerializadorFechasExceptuadasDomainService = serializadorFechasExceptuadasDomainService;
        }

        public string ConstruirRegla(DefinirRecurrenciaEventoAgenda definirRecurrencia, DateTime fechaHoraInicio)
        {
            if (definirRecurrencia.Intervalo < 1)
                throw new ValidacionDominioException(Mensajes.ReglaRecurrenciaInvalida);

            var patronRecurrencia = new RecurrencePattern(
                IcalNetHelper.GetFrecuencyType(definirRecurrencia.FrecuenciaRecurrencia),
                definirRecurrencia.Intervalo);

            if (definirRecurrencia.FechaFin.HasValue)
            {
                if (definirRecurrencia.FechaFin.Value <= fechaHoraInicio)
                    throw new ValidacionDominioException(Mensajes.FechaFinRecurrenciaInvalida);

                patronRecurrencia.Until = IcalNetHelper.DateTimeToCalDateTimeArgentina(definirRecurrencia.FechaFin.Value);
            }

            return new RecurrenceRuleSerializer().SerializeToString(patronRecurrencia);
        }

        public bool EsReglaValida(string regla)
        {
            try
            {
                var patronRecurrencia = new RecurrencePattern(IcalNetHelper.ParseRule(regla));

                return patronRecurrencia is not null;
            }
            catch (Exception)
            {
                return false;
            }
        }

        public List<DateTime> ExpandirOcurrencias(string regla, DateTime inicioBase, string? excepciones, DateTime desde, DateTime hasta)
        {
            var fechaDesdeCal = IcalNetHelper.DateTimeToCalDateTimeArgentina(desde);
            var fechaHastaCal = IcalNetHelper.DateTimeToCalDateTimeArgentina(hasta);

            var eventoCalendario = new CalendarEvent
            {
                Start = IcalNetHelper.DateTimeToCalDateTimeArgentina(inicioBase),
                RecurrenceRule = new RecurrencePattern(IcalNetHelper.ParseRule(regla))
            };

            if (!string.IsNullOrWhiteSpace(excepciones))
            {
                var fechasExceptuadas = this.SerializadorFechasExceptuadasDomainService.DeserializarFechasExceptuadas(excepciones);

                eventoCalendario.ExceptionDates.AddRange(fechasExceptuadas.Select(f => IcalNetHelper.DateTimeToCalDateTimeArgentina(f)));
            }

            return eventoCalendario
                .GetOccurrences(fechaDesdeCal)
                .TakeWhileBefore(fechaHastaCal)
                .Select(o => DateTime.SpecifyKind(o.Period.StartTime.ToTimeZone(ZonasHorarias.Argentina).Value, DateTimeKind.Unspecified))
                .OrderBy(d => d)
                .ToList();
        }
    }
}
