using CareWell.Domain.ValueObjects.Salud;
using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;

namespace CareWell.Domain.Salud
{
    public class FichaSaludAlergia : BaseEntity
    {
        public virtual FichaSalud FichaSalud { get; private set; }

        public virtual string Nombre { get; private set; }

        public virtual string Reaccion { get; private set; }

        public virtual string? Medicamento { get; private set; }

        public virtual void Registrar(AgregarAlergia agregarAlergia, FichaSalud fichaSalud)
        {
            if (string.IsNullOrEmpty(agregarAlergia.Nombre))
                throw new ValidacionDominioException(Mensajes.NombreAlergiaRequerido);

            if (string.IsNullOrEmpty(agregarAlergia.Reaccion))
                throw new ValidacionDominioException(Mensajes.ReaccionAlergiaRequerido);

            this.FichaSalud = fichaSalud;
            this.Nombre = agregarAlergia.Nombre;
            this.Reaccion = agregarAlergia.Reaccion;
            this.Medicamento = agregarAlergia.Medicamento;
        }
    }
}
