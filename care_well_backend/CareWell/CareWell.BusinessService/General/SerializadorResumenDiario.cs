using CareWell.BusinessService.Abstractions.General;
using CareWell.DataViews.General;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace CareWell.BusinessService.General
{
    public class SerializadorResumenDiario : ISerializadorResumenDiario
    {
        private static readonly JsonSerializerOptions Opciones = new JsonSerializerOptions
        {
            PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
            PropertyNameCaseInsensitive = true,
            DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull
        };

        public string Serializar(ResumenDiarioDataView resumenDiario)
        {
            return JsonSerializer.Serialize(resumenDiario, Opciones);
        }

        public ResumenDiarioDataView? Deserializar(string contenido)
        {
            if (string.IsNullOrWhiteSpace(contenido))
                return null;

            try
            {
                return JsonSerializer.Deserialize<ResumenDiarioDataView>(contenido, Opciones);
            }
            catch (JsonException)
            {
                return null;
            }
        }
    }
}
