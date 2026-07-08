using CareWell.Domain.DomainServices.Salud;
using CareWell.Domain.Salud.AlertasBienestar;
using CareWell.Domain.ValueObjects.Salud;
using CareWell.Global.Constantes.Salud;

namespace CareWell.BusinessService.Salud
{
    public class DetectorAlertasBienestarBusinessService : IDetectorAlertasBienestarDomainService
    {
        private IDetectorAnimoBajoSostenido DetectorAnimoBajoSostenido { get; set; }
        private IDetectorDeterioroAnimo DetectorDeterioroAnimo { get; set; }
        private IDetectorAlertaHabito DetectorAlertaHabito { get; set; }

        public DetectorAlertasBienestarBusinessService(IDetectorAnimoBajoSostenido detectorAnimoBajoSostenido,
                                                       IDetectorDeterioroAnimo detectorDeterioroAnimo,
                                                       IDetectorAlertaHabito detectorAlertaHabito)
        {
            this.DetectorAnimoBajoSostenido = detectorAnimoBajoSostenido;
            this.DetectorDeterioroAnimo = detectorDeterioroAnimo;
            this.DetectorAlertaHabito = detectorAlertaHabito;
        }

        public List<AlertaBienestar> Detectar(DetectarAlertaBienestar detectarAlerta)
        {
            var fechaVentanaReciente = detectarAlerta.FechaReferencia.AddDays(-ParametrosDeteccionBienestar.DiasVentanaReciente);
            var fechaVentanaBase = detectarAlerta.FechaReferencia.AddDays(-(ParametrosDeteccionBienestar.DiasVentanaReciente + ParametrosDeteccionBienestar.DiasVentanaBase));

            var alertas = new List<AlertaBienestar>();

            var alertaAnimoBajo = this.DetectorAnimoBajoSostenido.Detectar(detectarAlerta.EstadosAnimo,
                                                                           detectarAlerta.FechaReferencia);
            if (alertaAnimoBajo is not null)
                alertas.Add(alertaAnimoBajo);

            var alertaDeterioro = this.DetectorDeterioroAnimo.Detectar(detectarAlerta.EstadosAnimo,
                                                                       detectarAlerta.FechaReferencia,
                                                                       fechaVentanaReciente,
                                                                       fechaVentanaBase);
            if (alertaDeterioro is not null)
                alertas.Add(alertaDeterioro);

            foreach (var habito in detectarAlerta.HabitosVida)
            {
                var alertaHabito = this.DetectorAlertaHabito.Detectar(habito,
                                                                      detectarAlerta.FechaReferencia,
                                                                      fechaVentanaReciente,
                                                                      fechaVentanaBase);
                if (alertaHabito is not null)
                    alertas.Add(alertaHabito);
            }

            return alertas;
        }
    }
}
