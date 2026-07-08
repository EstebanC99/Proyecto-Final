using CareWell.Domain.Factories;
using CareWell.Global.Constantes.Salud;

namespace CareWell.Domain.Salud.AlertasBienestar
{
    public class DetectorAlertaHabito : IDetectorAlertaHabito
    {
        private IBaseFactory Factory { get; set; }

        public DetectorAlertaHabito(IBaseFactory baseFactory)
        {
            this.Factory = baseFactory;
        }

        public AlertaBienestar? Detectar(HabitoVida habitoVida, DateTime fechaReferencia, DateTime inicioReciente, DateTime inicioBase)
        {
            if (!habitoVida.Activo)
                return null;

            var antiguedadDias = (fechaReferencia - habitoVida.FechaCreacion).TotalDays;
            if (antiguedadDias < ParametrosDeteccionBienestar.DiasAntiguedadMinimaHabito)
                return null;

            var realizacionesBase = habitoVida.Realizaciones
                .Count(r => r.FechaHoraRealizacion > inicioBase && r.FechaHoraRealizacion <= inicioReciente);

            if (realizacionesBase < ParametrosDeteccionBienestar.MinRealizacionesBaseHabito)
                return null;

            var realizacionesReciente = habitoVida.Realizaciones
                .Count(r => r.FechaHoraRealizacion > inicioReciente && r.FechaHoraRealizacion <= fechaReferencia);

            if (realizacionesReciente == default)
            {
                var ultimaRealizacion = habitoVida.Realizaciones.Max(r => r.FechaHoraRealizacion);
                var diasSinRegistrar = (int)(fechaReferencia.Date - ultimaRealizacion.Date).TotalDays;

                var alertaBienestar = this.Factory.Crear<AlertaBienestar>();
                alertaBienestar.RegistrarAbandonoHabito(diasSinRegistrar, fechaReferencia, habitoVida);

                return alertaBienestar;
            }

            var tasaBaseSemanal = (double)realizacionesBase / ParametrosDeteccionBienestar.DiasVentanaBase * ParametrosDeteccionBienestar.DiasVentanaReciente;
            var tasaRecienteSemanal = (double)realizacionesReciente;

            if (tasaRecienteSemanal < ParametrosDeteccionBienestar.UmbralCaidaCumplimiento * tasaBaseSemanal)
            {
                var alertaBienestar = this.Factory.Crear<AlertaBienestar>();
                alertaBienestar.RegistrarCaidaCumplimientoHabito(fechaReferencia, habitoVida);

                return alertaBienestar;
            }

            return null;
        }
    }
}
