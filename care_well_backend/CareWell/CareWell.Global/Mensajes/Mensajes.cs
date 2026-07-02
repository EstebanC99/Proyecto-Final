namespace CareWell.Global.Mensajes
{
    public abstract class Mensajes
    {
        public const string AnticipacionRecordatorioInvalida = "La anticipación del recordatorio elegida para el evento no es válida.";
        public const string ApellidoRequerido = "El apellido es requerido.";
        public const string ColaboradorRequerido = "El usuario elegido no existe como colaborador.";
        public const string ContrasenaRequerida = "La contraseña es requerida.";
        public const string DebeSeleccionarUnoMasPermisos = "Debe seleccionar uno o más permisos.";
        public const string DocumentoRequerido = "El documento es requerido.";
        public const string DuracionEventoInvalida = "La duración elegida para el evento no es válida.";
        public const string EmailRequerido = "El email es requerido.";
        public const string EstadoAsignacionNoPermiteEjecutarAccion = "El estado de la asignación no permite ejecutar la acción.";
        public const string FechaFinRecurrenciaInvalida = "La fecha de fin de recurrencia no es válida.";
        public const string FechaHoraInicioEventoRequerida = "La fecha y hora de inicio del evento es requerida.";
        public const string FechaNacimientoRequerida = "La fecha de nacimiento es requerida.";
        public const string NombreRequerido = "El nombre es requerido.";
        public const string NombreUsuarioEnUso = "El nombre de usuario ingresado ya esta en uso.";
        public const string NoPuedeReactivarUnaAsignacionPasadoLos30Dias = "No puede reactivar una asignación, pasados los 30 días desde su inactivación.";
        public const string NoSePuedeActivarUnaAsignacionConEstadoDiferentePendiente = "No es posible activar una asignación con estado diferente a 'Pendiente'.";
        public const string NoSePuedeEliminarEventoYaIniciado = "No se puede eliminar un evento ya iniciado.";
        public const string NoSePuedeModificarEventoYaIniciado = "No se puede modificar un evento ya iniciado.";
        public const string PersonaColaboradorRequerido = "La persona elegida no existe como colaborador.";
        public const string PersonaNoExiste = "La persona ingresada no existe.";
        public const string ReglaRecurrenciaInvalida = "La regla de recurrencia elegida para el evento no es válida.";
        public const string RolCuidadoRequerido = "Debe especificar un rol para la persona a asignar.";
        public const string TelefonoRequerido = "El teléfono es requerido.";
        public const string TipoEventoNoEsAgendable = "El tipo de evento elegido no es agendable.";
        public const string TipoEventoRequerido = "El tipo de evento es requerido.";
        public const string TituloEventoRequerido = "El titulo del evento es requerido.";
        public const string UsuarioNoHabilitadoParaEjecutarAccion = "Usuario no habilitado para ejecutar la acción.";
        public const string YaExisteUnaAsignacionRegistradaParaElColaboradorSeleccionado = "Ya existe una asignación registrada para el colaborador seleccionado.";
        public const string ElEventoNoEsRecurrente = "El evento seleccionado no es recurrente.";
        public const string NoSePuedeCancelarOcurrenciaPasada = "No se puede cancelar una ocurrencia de evento pasado.";
        public const string ElEventoAgendaEsRequeridoParaElEventoSalud = "El evento de agenda correspondiente es requerido para el evento de salud.";
        public const string ElEventoAgendaNoGeneraEventoSalud = "El evento de agenda elegido, no genera un evento de salud.";
    }
}
