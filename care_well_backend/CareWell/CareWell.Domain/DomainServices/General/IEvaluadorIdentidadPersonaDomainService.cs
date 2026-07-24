using CareWell.Domain.General;

namespace CareWell.Domain.DomainServices.General
{
    public interface IEvaluadorIdentidadPersonaDomainService
    {
        bool EsIdentidadCorrecta(Persona persona, byte[]? imagenDocumento);
    }
}
