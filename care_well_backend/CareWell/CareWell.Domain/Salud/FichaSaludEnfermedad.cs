using CareWell.Domain.ValueObjects.Salud;
using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;

namespace CareWell.Domain.Salud
{
    public class FichaSaludEnfermedad : BaseEntity
    {
        public virtual FichaSalud FichaSalud { get; private set; }

        public virtual string Nombre { get; private set; }

        public virtual bool Vigente { get; private set; }

        public virtual string? Observacion { get; private set; }

        public virtual void Registrar(AgregarEnfermedad agregarEnfermedad, FichaSalud fichaSalud)
        {
            if (string.IsNullOrEmpty(agregarEnfermedad.Nombre))
                throw new ValidacionDominioException(Mensajes.NombreEnfermedadRequerido);

            this.FichaSalud = fichaSalud;
            this.Nombre = agregarEnfermedad.Nombre;
            this.Vigente = agregarEnfermedad.Vigente;
            this.Observacion = agregarEnfermedad.Observacion;
        }
    }
}
