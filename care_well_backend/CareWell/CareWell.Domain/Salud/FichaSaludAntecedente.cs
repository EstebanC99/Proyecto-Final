using CareWell.Domain.ValueObjects.Salud;
using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;

namespace CareWell.Domain.Salud
{
    public class FichaSaludAntecedente : BaseEntity
    {
        public virtual FichaSalud FichaSalud { get; private set; }

        public virtual string Nombre { get; private set; }

        public virtual string Descripcion { get; private set; }

        public virtual string VinculoFamiliar { get; private set; }

        public virtual void Registrar(AgregarAntecedente agregarAntecedente, FichaSalud fichaSalud)
        {
            if (string.IsNullOrEmpty(agregarAntecedente.Nombre))
                throw new ValidacionDominioException(Mensajes.NombreAntecedenteRequerido);

            if (string.IsNullOrEmpty(agregarAntecedente.Descripcion))
                throw new ValidacionDominioException(Mensajes.DescripcionAntecedenteRequerido);

            if (string.IsNullOrEmpty(agregarAntecedente.VinculoFamiliar))
                throw new ValidacionDominioException(Mensajes.VinculoAntecedenteRequerido);

            this.FichaSalud = fichaSalud;
            this.Nombre = agregarAntecedente.Nombre;
            this.Descripcion = agregarAntecedente.Descripcion;
            this.VinculoFamiliar = agregarAntecedente.VinculoFamiliar;
        }
    }
}
