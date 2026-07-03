using CareWell.Domain.General;
using CareWell.Domain.ValueObjects.Salud;
using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;

namespace CareWell.Domain.Salud
{
    public class NotaEventoSalud : BaseEntity
    {
        public virtual Persona Autor { get; private set; }

        public virtual DateTime FechaHora { get; private set; }

        public virtual string Contenido { get; private set; }

        public virtual EventoSalud EventoSalud { get; private set; }

        public virtual void Crear(CrearNotaEventoSalud crearNota,
                                  EventoSalud eventoSalud)
        {
            if (crearNota.Autor is null)
                throw new ValidacionDominioException(Mensajes.AutorRequeridoParaNotaDeSalud);

            if (string.IsNullOrEmpty(crearNota.Contenido))
                throw new ValidacionDominioException(Mensajes.ContenidoRequeridoParaNotaDeSalud);

            this.Autor = crearNota.Autor;
            this.FechaHora = DateTime.Now;
            this.Contenido = crearNota.Contenido;
            this.EventoSalud = eventoSalud;
        }

        public virtual void ModificarContenido(string contenido)
        {
            if (string.IsNullOrEmpty(contenido))
                throw new ValidacionDominioException(Mensajes.ContenidoRequeridoParaNotaDeSalud);

            this.Contenido = contenido;
        }
    }
}
