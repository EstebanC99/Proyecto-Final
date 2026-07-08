using CareWell.Domain.Factories;
using CareWell.Global.Constantes.Salud;

namespace CareWell.Domain.Salud.AlertasBienestar
{
    public class DetectorDeterioroAnimo : IDetectorDeterioroAnimo
    {
        private IBaseFactory Factory { get; set; }

        public DetectorDeterioroAnimo(IBaseFactory baseFactory)
        {
            this.Factory = baseFactory;
        }

        public AlertaBienestar? Detectar(List<PersonaEstadoAnimo> estadosAnimo, DateTime fechaReferencia, DateTime inicioReciente, DateTime inicioBase)
        {
            var recientes = estadosAnimo
                .Where(e => e.FechaHora > inicioReciente && e.FechaHora <= fechaReferencia)
                .ToList();

            var baseVentana = estadosAnimo
                .Where(e => e.FechaHora > inicioBase && e.FechaHora <= inicioReciente)
                .ToList();

            if (recientes.Count < ParametrosDeteccionBienestar.MinRegistrosAnimoReciente)
                return null;

            if (baseVentana.Count < ParametrosDeteccionBienestar.MinRegistrosAnimoBase)
                return null;

            var promedioReciente = recientes.Average(e => e.EstadoAnimo.ID);
            var promedioBase = baseVentana.Average(e => e.EstadoAnimo.ID);

            if (promedioReciente - promedioBase < ParametrosDeteccionBienestar.DeltaDeterioroAnimo)
                return null;

            var alertaBienestar = this.Factory.Crear<AlertaBienestar>();
            alertaBienestar.RegistrarDeterioroAnimo(estadosAnimo.First().Persona.Nombre, fechaReferencia);

            return alertaBienestar;
        }
    }
}
