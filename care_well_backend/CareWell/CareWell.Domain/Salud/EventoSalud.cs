using CareWell.Domain.Agenda;
using CareWell.Domain.Factories;
using CareWell.Domain.General;
using CareWell.Domain.Validadores;
using CareWell.Domain.ValueObjects.Salud;
using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;

namespace CareWell.Domain.Salud
{
    public class EventoSalud : BaseEntity
    {
        public virtual Persona Persona { get; private set; }

        public virtual TipoEvento Tipo { get; private set; }

        public virtual DateTime FechaHora { get; private set; }

        public virtual string Descripcion { get; private set; }

        public virtual List<NotaEventoSalud> Notas { get; private set; }

        public virtual EventoAgenda? EventoAgenda { get; private set; }

        public virtual DateTime? FechaOcurrenciaEventoAgenda { get; private set; }

        public EventoSalud()
        {
            this.Notas = new List<NotaEventoSalud>();
        }

        public virtual void GenerarDesdeAgenda(EventoAgenda eventoAgenda, DateTime fechaOcurrencia)
        {
            if (eventoAgenda is null)
                throw new ValidacionDominioException(Mensajes.ElEventoAgendaEsRequeridoParaElEventoSalud);

            if (!eventoAgenda.GenerarEventoSalud)
                throw new ValidacionDominioException(Mensajes.ElEventoAgendaNoGeneraEventoSalud);

            this.Persona = eventoAgenda.Persona;
            this.Tipo = eventoAgenda.Tipo;
            this.FechaHora = fechaOcurrencia;
            this.Descripcion = eventoAgenda.Titulo;
            this.EventoAgenda = eventoAgenda;
            this.FechaOcurrenciaEventoAgenda = fechaOcurrencia;
        }

        public virtual void Crear(CrearEventoSalud crearEventoSalud,
                                  IValidadorPermisoAccion validadorPermisoAccion)
        {
            validadorPermisoAccion.ValidarPuedeAdministrarEventosSalud(crearEventoSalud.Persona, crearEventoSalud.Colaborador);

            if (crearEventoSalud.Persona is null)
                throw new ValidacionDominioException(Mensajes.PersonaNoExiste);

            if (crearEventoSalud.Tipo is null)
                throw new ValidacionDominioException(Mensajes.TipoEventoRequerido);

            if (crearEventoSalud.FechaHora == default)
                throw new ValidacionDominioException(Mensajes.FechaHoraInicioEventoRequerida);

            if (string.IsNullOrEmpty(crearEventoSalud.Descripcion))
                throw new ValidacionDominioException(Mensajes.LaDescripcionEsRequerida);

            this.Persona = crearEventoSalud.Persona;
            this.Tipo = crearEventoSalud.Tipo;
            this.FechaHora = crearEventoSalud.FechaHora;
            this.Descripcion = crearEventoSalud.Descripcion;
        }

        public virtual void Eliminar(Persona colaborador,
                                     IValidadorPermisoAccion validadorPermisoAccion)
        {
            validadorPermisoAccion.ValidarPuedeAdministrarEventosSalud(this.Persona, colaborador);

            this.Notas.Clear();
        }

        public virtual void AgregarNota(CrearNotaEventoSalud crearNotaEventoSalud,
                                        IValidadorPermisoAccion validadorPermisoAccion,
                                        IBaseFactory baseFactory)
        {
            validadorPermisoAccion.ValidarPuedeAdministrarEventosSalud(this.Persona, crearNotaEventoSalud.Autor);

            var notaEvento = baseFactory.Crear<NotaEventoSalud>();

            notaEvento.Crear(crearNotaEventoSalud,
                             this);

            this.Notas.Add(notaEvento);
        }

        public virtual void ModificarNota(ModificarNotaEventoSalud modificarNotaEventoSalud,
                                          IValidadorPermisoAccion validadorPermisoAccion)
        {
            validadorPermisoAccion.ValidarPuedeAdministrarEventosSalud(this.Persona, modificarNotaEventoSalud.Colaborador);

            var nota = this.Notas.FirstOrDefault(n => n.ID == modificarNotaEventoSalud.NotaID);

            if (nota is null)
                throw new ValidacionDominioException(Mensajes.NotaNoEncontrada);

            nota.ModificarContenido(modificarNotaEventoSalud.Contenido);
        }

        public virtual void EliminarNota(EliminarNotaEventoSalud eliminarNotaEventoSalud,
                                         IValidadorPermisoAccion validadorPermisoAccion)
        {
            validadorPermisoAccion.ValidarPuedeAdministrarEventosSalud(this.Persona, eliminarNotaEventoSalud.Colaborador);

            var nota = this.Notas.FirstOrDefault(n => n.ID == eliminarNotaEventoSalud.NotaID);

            if (nota is null)
                throw new ValidacionDominioException(Mensajes.NotaNoEncontrada);

            this.Notas.Remove(nota);
        }
    }
}
