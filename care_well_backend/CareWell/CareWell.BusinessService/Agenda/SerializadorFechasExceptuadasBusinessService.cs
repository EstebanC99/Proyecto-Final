using CareWell.Domain.DomainServices.Agenda;
using System.Globalization;

namespace CareWell.BusinessService.Agenda
{
    public class SerializadorFechasExceptuadasBusinessService : ISerializadorFechasExceptuadasDomainService
    {
        public string? SerializarFechasExceptuadas(List<DateTime> fechas)
        {
            if (fechas is null || !fechas.Any())
                return null;

            return string.Join(";", fechas.Order().Select(f => f.ToString("O", CultureInfo.InvariantCulture)));
        }

        public List<DateTime> DeserializarFechasExceptuadas(string? fechasSerializadas)
        {
            var fechasDeserializadas = new List<DateTime>();

            if (!string.IsNullOrEmpty(fechasSerializadas))
            {
                var fechasString = fechasSerializadas.Split(';', StringSplitOptions.RemoveEmptyEntries);

                foreach (var fechaString in fechasString)
                {
                    var fecha = DateTime.Parse(fechaString, CultureInfo.InvariantCulture, DateTimeStyles.RoundtripKind);

                    fechasDeserializadas.Add(fecha);
                }
            }

            return fechasDeserializadas;
        }
    }
}
