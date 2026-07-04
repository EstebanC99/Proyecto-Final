using CareWell.Domain.General;
using CareWell.Domain.Validadores;
using CareWell.Domain.ValueObjects.Salud;
using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;

namespace CareWell.Domain.Salud
{
    public class PersonaEstadoAnimo : BaseEntity
    {
        public virtual Persona Persona { get; private set; }

        public virtual DateTime FechaHora { get; private set; }

        public virtual EstadoAnimo EstadoAnimo { get; private set; }

        public virtual string? Observaciones { get; private set; }

        public virtual void Registrar(RegistrarEstadoAnimo registrarEstadoAnimo,
                                      IValidadorPermisoAccion validadorPermisoAccion)
        {
            if (registrarEstadoAnimo.Persona is null)
                throw new ValidacionDominioException(Mensajes.PersonaNoExiste);

            validadorPermisoAccion.ValidarVisualizacion(registrarEstadoAnimo.Persona, registrarEstadoAnimo.Colaborador);

            if (registrarEstadoAnimo.EstadoAnimo is null)
                throw new ValidacionDominioException(Mensajes.EstadoAnimoRequerido);

            this.Persona = registrarEstadoAnimo.Persona;
            this.FechaHora = DateTime.Now;
            this.EstadoAnimo = registrarEstadoAnimo.EstadoAnimo;
            this.Observaciones = registrarEstadoAnimo.Observaciones;
        }
    }
}
