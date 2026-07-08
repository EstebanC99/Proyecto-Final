using CareWell.Domain.Factories;
using CareWell.Global.Constantes.Salud;

namespace CareWell.Domain.Salud.AlertasBienestar
{
    public class DetectorAnimoBajoSostenido : IDetectorAnimoBajoSostenido
    {
        private IBaseFactory Factory { get; set; }

        public DetectorAnimoBajoSostenido(IBaseFactory baseFactory)
        {
            this.Factory = baseFactory;
        }

        public AlertaBienestar? Detectar(List<PersonaEstadoAnimo> estadosAnimo, DateTime fechaReferencia)
        {
            var masRecientes = estadosAnimo
                .OrderByDescending(e => e.FechaHora)
                .Take(ParametrosDeteccionBienestar.MinRegistrosConsecutivosAnimoBajo)
                .ToList();

            if (masRecientes.Count < ParametrosDeteccionBienestar.MinRegistrosConsecutivosAnimoBajo)
                return null;

            if (!masRecientes.All(e => e.EstadoAnimo.ID >= EstadosAnimo.Mal))
                return null;

            var lapsoDias = (masRecientes.First().FechaHora - masRecientes.Last().FechaHora).TotalDays;

            if (lapsoDias > ParametrosDeteccionBienestar.DiasLapsoMaximoAnimoBajo)
                return null;

            var severidad = masRecientes.All(e => e.EstadoAnimo.ID == EstadosAnimo.MuyMal)
                ? SeveridadesAlertaBienestar.Alta
                : SeveridadesAlertaBienestar.Media;

            var alertaBienestar = this.Factory.Crear<AlertaBienestar>();
            alertaBienestar.RegistrarAnimoBajoSostenido(severidad, estadosAnimo.First().Persona.Nombre, fechaReferencia);

            return alertaBienestar;
        }
    }
}
