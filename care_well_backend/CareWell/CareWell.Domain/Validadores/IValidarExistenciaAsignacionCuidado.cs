using CareWell.Domain.General;

namespace CareWell.Domain.Validadores
{
    public interface IValidarExistenciaAsignacionCuidado
    {
        bool ExisteAsignacionColaboradorElegido(Persona personaCuidada, Persona colaborador);
    }
}