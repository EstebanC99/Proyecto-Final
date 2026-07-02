using CareWell.Global.Constantes.Agenda;
using CareWell.Global.Enumeraciones.Agenda;
using Ical.Net;
using Ical.Net.DataTypes;

namespace CareWell.BusinessService.Helpers
{
    public static class IcalNetHelper
    {
        public static FrequencyType GetFrecuencyType(FrecuenciaRecurrenciaEnum frecuenciaRecurrenciaEnum)
        {
            return frecuenciaRecurrenciaEnum switch
            {
                FrecuenciaRecurrenciaEnum.Diaria => FrequencyType.Daily,
                FrecuenciaRecurrenciaEnum.Semanal => FrequencyType.Weekly,
                FrecuenciaRecurrenciaEnum.Mensual => FrequencyType.Monthly,
                _ => throw new ArgumentOutOfRangeException(nameof(frecuenciaRecurrenciaEnum)),
            };
        }

        public static CalDateTime DateTimeToCalDateTimeArgentina(DateTime fecha, bool hasTime = true)
        {
            return new CalDateTime
            (
                DateTime.SpecifyKind(fecha, DateTimeKind.Unspecified),
                ZonasHorarias.Argentina,
                hasTime
            );
        }

        public static string ParseRule(string regla)
        {
            return regla.Replace("RRULE:", string.Empty);
        }
    }
}
