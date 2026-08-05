using CareWell.Domain.General;
using CareWell.Domain.Validadores;
using CareWell.Domain.ValueObjects.General;
using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;

namespace CareWell.Domain.Emergencias
{
    public class Emergencia : BaseEntity
    {
        public virtual Persona Persona { get; private set; }
        
        public virtual Persona Activador { get; private set; }

        public virtual DateTime FechaHora { get; private set; }

        public virtual string? Descripcion { get; private set; }

        public virtual void Activar(ActivarEmergencia activarEmergencia, IValidadorPermisoAccion validadorPermisoAccion)
        {
            if (activarEmergencia.Persona is null)
                throw new ValidacionDominioException(Mensajes.PersonaNoExiste);

            if (activarEmergencia.Activador is null)
                throw new ValidacionDominioException(Mensajes.ActivadorEmergenciaRequerido);

            validadorPermisoAccion.ValidarPuedeActivarEmergencia(activarEmergencia.Persona, activarEmergencia.Activador);

            this.Persona = activarEmergencia.Persona;
            this.Activador = activarEmergencia.Activador;
            this.Descripcion = activarEmergencia.Descripcion;
            this.FechaHora = DateTime.Now;
        }
    }
}
