using CareWell.DataViews.General;

namespace CareWell.BusinessService.Abstractions.General
{
    public interface ISerializadorResumenDiario
    {
        string Serializar(ResumenDiarioDataView resumenDiario);
        ResumenDiarioDataView? Deserializar(string contenido);
    }
}
