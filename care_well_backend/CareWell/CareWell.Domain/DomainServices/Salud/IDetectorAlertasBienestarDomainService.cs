using CareWell.Domain.Salud.AlertasBienestar;
using CareWell.Domain.ValueObjects.Salud;

namespace CareWell.Domain.DomainServices.Salud
{
    public interface IDetectorAlertasBienestarDomainService
    {
        List<AlertaBienestar> Detectar(DetectarAlertaBienestar detectarAlertaBienestar);
    }
}
