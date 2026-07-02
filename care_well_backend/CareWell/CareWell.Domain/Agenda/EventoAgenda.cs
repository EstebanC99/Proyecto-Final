using CareWell.Domain.DomainServices.Agenda;
using CareWell.Domain.General;
using CareWell.Domain.Validadores;
using CareWell.Domain.ValueObjects.Agenda;
using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;

namespace CareWell.Domain.Agenda
{
    public class EventoAgenda : BaseEntity
    {
        public virtual Persona Persona { get; private set; }

        public virtual Persona Creador { get; private set; }

        public virtual string Titulo { get; private set; }

        public virtual string? Descripcion { get; private set; }

        public virtual TipoEvento Tipo { get; private set; }

        public virtual DateTime FechaHoraInicio { get; private set; }

        public virtual TimeSpan Duracion { get; private set; }

        public virtual string? ReglaRecurrencia { get; private set; }

        public virtual string? FechasExceptuadas { get; private set; }

        public virtual bool GenerarEventoSalud { get; private set; }

        public virtual DateTime? FechaUltimaGeneracionEventoSalud { get; private set; }

        public virtual int? MinutosAnticipacionRecordatorio { get; private set; }

        public virtual void Crear(CrearEventoAgenda crearEventoAgenda,
                                  IExpansorRecurrenciaDomainService expansorRecurrenciaDomainService,
                                  IValidadorPermisoAccion validadorPermisoAccion)
        {
            if (crearEventoAgenda.Persona is null)
                throw new ValidacionDominioException(Mensajes.PersonaNoExiste);

            ValidarCamposObligatorios(crearEventoAgenda);

            validadorPermisoAccion.ValidarPuedeAdministrarAgenda(crearEventoAgenda.Persona, crearEventoAgenda.Creador);

            this.Persona = crearEventoAgenda.Persona;
            this.Creador = crearEventoAgenda.Creador;

            this.SetearCamposEditables(crearEventoAgenda, expansorRecurrenciaDomainService);
        }

        public virtual void Modificar(ModificarEventoAgenda modificarEventoAgenda,
                                      IExpansorRecurrenciaDomainService expansorRecurrenciaDomainService,
                                      IValidadorPermisoAccion validadorPermisoAccion)
        {
            ValidarCamposObligatorios(modificarEventoAgenda);

            validadorPermisoAccion.ValidarPuedeAdministrarAgenda(this.Persona, modificarEventoAgenda.Solicitante);

            if (this.FechaHoraInicio <= DateTime.Now)
                throw new ValidacionDominioException(Mensajes.NoSePuedeModificarEventoYaIniciado);

            this.SetearCamposEditables(modificarEventoAgenda, expansorRecurrenciaDomainService);
        }

        public virtual void CancelarOcurrencia(DateTime fechaOcurrencia,
                                               Persona solicitante,
                                               ISerializadorFechasExceptuadasDomainService serializadorFechasExceptuadas,
                                               IValidadorPermisoAccion validadorPermisoAccion)
        {
            validadorPermisoAccion.ValidarPuedeAdministrarAgenda(this.Persona, solicitante);

            if (string.IsNullOrEmpty(this.ReglaRecurrencia))
                throw new ValidacionDominioException(Mensajes.ElEventoNoEsRecurrente);

            if (fechaOcurrencia <= DateTime.Now)
                throw new ValidacionDominioException(Mensajes.NoSePuedeCancelarOcurrenciaPasada);

            var fechasExceptuadas = serializadorFechasExceptuadas.DeserializarFechasExceptuadas(this.FechasExceptuadas);

            if (!fechasExceptuadas.Contains(fechaOcurrencia))
                fechasExceptuadas.Add(fechaOcurrencia);

            this.FechasExceptuadas = serializadorFechasExceptuadas.SerializarFechasExceptuadas(fechasExceptuadas);
        }

        public virtual void ActualizarUltimaGeneracionEventoSalud(DateTime fechaUltimaGeneracionEventoSalud)
        {
            if (!this.FechaUltimaGeneracionEventoSalud.HasValue || this.FechaUltimaGeneracionEventoSalud < fechaUltimaGeneracionEventoSalud)
                this.FechaUltimaGeneracionEventoSalud = fechaUltimaGeneracionEventoSalud;
        }

        public virtual void Eliminar(IValidadorPermisoAccion validadorPermisoAccion,
                                     Persona solicitante)
        {
            validadorPermisoAccion.ValidarPuedeAdministrarAgenda(this.Persona, solicitante);

            if (this.FechaHoraInicio <= DateTime.Now)
                throw new ValidacionDominioException(Mensajes.NoSePuedeEliminarEventoYaIniciado);
        }

        public virtual List<DateTime> ObtenerOcurrencias(IExpansorRecurrenciaDomainService expansorRecurrenciaDomainService,
                                                         DateTime fechaHoraActual)
        {
            var fechaHoraDesde = this.FechaUltimaGeneracionEventoSalud ?? this.FechaHoraInicio;

            return this.ObtenerOcurrenciasEnRango(expansorRecurrenciaDomainService,
                                                  fechaHoraDesde,
                                                  fechaHoraActual);
        }

        public virtual List<DateTime> ObtenerOcurrenciasEnRango(IExpansorRecurrenciaDomainService expansorRecurrenciaDomainService,
                                                                DateTime fechaHoraDesde,
                                                                DateTime fechaHoraHasta)
        {
            if (this.ReglaRecurrencia is not null)
                return expansorRecurrenciaDomainService.ExpandirOcurrencias(this.ReglaRecurrencia,
                                                                            this.FechaHoraInicio,
                                                                            this.FechasExceptuadas,
                                                                            fechaHoraDesde,
                                                                            fechaHoraHasta);

            if (this.FechaHoraInicio >= fechaHoraDesde && this.FechaHoraInicio < fechaHoraHasta)
                return new List<DateTime> { this.FechaHoraInicio };

            return new List<DateTime>();
        }

        #region Metodos Privados

        private static void ValidarCamposObligatorios(CrearEventoAgenda crearEventoAgenda)
        {
            if (string.IsNullOrEmpty(crearEventoAgenda.Titulo))
                throw new ValidacionDominioException(Mensajes.TituloEventoRequerido);

            if (crearEventoAgenda.FechaHoraInicio == default)
                throw new ValidacionDominioException(Mensajes.FechaHoraInicioEventoRequerida);

            if (crearEventoAgenda.Duracion <= TimeSpan.Zero)
                throw new ValidacionDominioException(Mensajes.DuracionEventoInvalida);

            if (crearEventoAgenda.Tipo is null)
                throw new ValidacionDominioException(Mensajes.TipoEventoRequerido);

            if (!crearEventoAgenda.Tipo.Agendable)
                throw new ValidacionDominioException(Mensajes.TipoEventoNoEsAgendable);

            if (crearEventoAgenda.MinutosAnticipacionRecordatorio.HasValue && crearEventoAgenda.MinutosAnticipacionRecordatorio <= 0)
                throw new ValidacionDominioException(Mensajes.AnticipacionRecordatorioInvalida);
        }

        private void SetearCamposEditables(CrearEventoAgenda crearEventoAgenda, IExpansorRecurrenciaDomainService expansorRecurrenciaDomainService)
        {
            this.Titulo = crearEventoAgenda.Titulo;
            this.Descripcion = crearEventoAgenda.Descripcion;
            this.Tipo = crearEventoAgenda.Tipo;
            this.FechaHoraInicio = crearEventoAgenda.FechaHoraInicio;
            this.Duracion = crearEventoAgenda.Duracion;

            this.GenerarEventoSalud = crearEventoAgenda.GenerarEventoSalud;
            this.MinutosAnticipacionRecordatorio = crearEventoAgenda.MinutosAnticipacionRecordatorio;

            string? reglaRecurrenciaGenerada = null;

            if (crearEventoAgenda.Recurrencia is not null)
                reglaRecurrenciaGenerada = expansorRecurrenciaDomainService.ConstruirRegla(crearEventoAgenda.Recurrencia, crearEventoAgenda.FechaHoraInicio);

            if (this.ReglaRecurrencia != reglaRecurrenciaGenerada)
                this.FechasExceptuadas = null;

            this.ReglaRecurrencia = reglaRecurrenciaGenerada;
        }

        #endregion
    }
}
