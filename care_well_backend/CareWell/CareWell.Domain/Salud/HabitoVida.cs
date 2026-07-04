using CareWell.Domain.Factories;
using CareWell.Domain.General;
using CareWell.Domain.Validadores;
using CareWell.Domain.ValueObjects.Salud;
using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;

namespace CareWell.Domain.Salud
{
    public class HabitoVida : BaseEntity
    {
        public virtual Persona Persona { get; private set; }

        public virtual TipoHabitoVida Tipo { get; private set; }

        public virtual string Descripcion { get; private set; }

        public virtual bool Activo { get; private set; }

        public virtual List<HabitoVidaRealizacion> Realizaciones { get; private set; }

        public HabitoVida()
        {
            this.Realizaciones = new List<HabitoVidaRealizacion>();
        }

        public virtual void Crear(CrearHabitoVida crearHabitoVida,
                                  IValidadorPermisoAccion validadorPermisoAccion)
        {
            if (crearHabitoVida.Persona is null)
                throw new ValidacionDominioException(Mensajes.PersonaNoExiste);

            validadorPermisoAccion.ValidarPuedeRegistrarHabitos(crearHabitoVida.Persona, crearHabitoVida.Colaborador);

            if (crearHabitoVida.TipoHabito is null)
                throw new ValidacionDominioException(Mensajes.TipoHabitoRequerido);

            if (string.IsNullOrEmpty(crearHabitoVida.Descripcion))
                throw new ValidacionDominioException(Mensajes.LaDescripcionEsRequerida);

            this.Persona = crearHabitoVida.Persona;
            this.Tipo = crearHabitoVida.TipoHabito;
            this.Descripcion = crearHabitoVida.Descripcion;
            this.Activo = true;
        }

        public virtual void Modificar(ModificarHabitoVida modificarHabitoVida,
                                      IValidadorPermisoAccion validadorPermisoAccion)
        {
            if (!this.Activo)
                throw new ValidacionDominioException(Mensajes.NoSePuedeModificarUnHabitoInactivo);

            validadorPermisoAccion.ValidarPuedeRegistrarHabitos(this.Persona, modificarHabitoVida.Colaborador);

            if (modificarHabitoVida.TipoHabito is null)
                throw new ValidacionDominioException(Mensajes.TipoHabitoRequerido);

            if (string.IsNullOrEmpty(modificarHabitoVida.Descripcion))
                throw new ValidacionDominioException(Mensajes.LaDescripcionEsRequerida);

            this.Tipo = modificarHabitoVida.TipoHabito;
            this.Descripcion = modificarHabitoVida.Descripcion;
        }

        public virtual void Eliminar(Persona colaborador,
                                     IValidadorPermisoAccion validadorPermisoAccion)
        {
            validadorPermisoAccion.ValidarPuedeRegistrarHabitos(this.Persona, colaborador);

            this.Activo = false;
        }

        public virtual void CrearRealizacion(string? comentarios,
                                             IBaseFactory baseFactory)
        {
            if (!this.Activo)
                throw new ValidacionDominioException(Mensajes.NoSePuedeIndicarRealizacionDeUnHabitoInactivo);

            var realizacion = baseFactory.Crear<HabitoVidaRealizacion>();

            realizacion.Crear(this,
                              comentarios);

            this.Realizaciones.Add(realizacion);
        }

        public virtual void ModificarRealizacion(int realizacionID,
                                                 string? comentarios)
        {
            var realizacion = this.Realizaciones.FirstOrDefault(r => r.ID == realizacionID);

            if (realizacion is null)
                throw new ValidacionDominioException(Mensajes.NoSePudoEncontrarLaRealizacionDeHabitoSeleccionada);

            realizacion.Modificar(comentarios);
        }

        public virtual void EliminarRealizacion(int realizacionID)
        {
            var realizacion = this.Realizaciones.FirstOrDefault(r => r.ID == realizacionID);

            if (realizacion is null)
                throw new ValidacionDominioException(Mensajes.NoSePudoEncontrarLaRealizacionDeHabitoSeleccionada);

            this.Realizaciones.Remove(realizacion);
        }
    }
}
