class ApiConfig {
  /// URL del backend en producción (VPS + Caddy, ver care_well_doc/Deploy/Caddyfile).
  static const _prodBaseUrl = 'https://api.estecarsoft.com.ar/';

  /// Dev tunnel usado durante el desarrollo local.
  static const _devBaseUrl = 'https://36l71ck5-5094.brs.devtunnels.ms/';

  /// `true` cuando el binario se compila con `--release`. Se usa
  /// `bool.fromEnvironment` en lugar de `kReleaseMode` para que toda la
  /// configuración siga siendo `const` y no dependa de Flutter.
  static const _isRelease = bool.fromEnvironment('dart.vm.product');

  /// Se puede pisar con `--dart-define=API_BASE_URL=...` o
  /// `--dart-define-from-file=.env[.production]`. Sin flags: producción en
  /// release, dev tunnel en debug.
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _isRelease ? _prodBaseUrl : _devBaseUrl,
  );

  static const connectTimeout = Duration(seconds: 30);
  static const receiveTimeout = Duration(seconds: 45);
  static const receiveTimeoutValidacionIdentidad = Duration(
    minutes: 2,
    seconds: 30,
  );
  static const receiveTimeoutResumenInteligente = Duration(
    minutes: 2,
    seconds: 30,
  );

  static const loginPath = '/api/Authorization/login';
  static const refreshPath = '/api/Authorization/refresh-token';

  static const cuentaPath = '/api/Cuenta/crear';
  static const crearCredencialesPath = '/api/Cuenta/crear-credenciales';
  static const reenviarCodigoPath = '/api/Cuenta/reenviar-codigo';
  static const verificarEmailPath = '/api/Cuenta/verificar-email';
  static const solicitarResetContrasenaPath =
      '/api/Cuenta/solicitar-reset-contrasena';
  static const confirmarResetContrasenaPath =
      '/api/Cuenta/confirmar-reset-contrasena';
  static const eliminarCuentaPath = '/api/Cuenta/eliminar-cuenta';

  static const modificarPerfil = '/api/AdministrarPersona/modificar-perfil';
  static String imagenPersonaPath(int personaId) =>
      '/api/AdministrarPersona/$personaId/imagen';

  static const crearPersonaCargoPath =
      '/api/AdministrarPersonasCargo/crear-persona-cargo';
  static const modificarPersonaCargoPath =
      '/api/AdministrarPersonasCargo/modificar-persona-cargo';
  static const obtenerMisAsignacionesPath =
      '/api/AdministrarPersonasCargo/obtener-mis-asignaciones';

  static const obtenerAsignacionesPorPersona =
      '/api/AdministrarEquipoCuidado/obtener-asignaciones';
  static const asignar = '/api/AdministrarEquipoCuidado/asignar';
  static const modificarPermisosAsignacion =
      '/api/AdministrarEquipoCuidado/modificar-permisos-asignacion';
  static const eliminarAsignacionPath =
      '/api/AdministrarEquipoCuidado/eliminar-asignacion';
  static const activarAsignacionPath =
      '/api/AdministrarEquipoCuidado/activar-asignacion';
  static const reactivarAsignacionPath =
      '/api/AdministrarEquipoCuidado/reactivar-asignacion';

  static const obtenerOcurrenciasAgendaPath =
      '/api/AdministrarEventoAgenda/obtener-ocurrencias';
  static const crearEventoAgendaPath = '/api/AdministrarEventoAgenda/crear';
  static const modificarEventoAgendaPath =
      '/api/AdministrarEventoAgenda/modificar';
  static const eliminarEventoAgendaPath =
      '/api/AdministrarEventoAgenda/eliminar';
  static const cancelarOcurrenciaAgendaPath =
      '/api/AdministrarEventoAgenda/cancelar-ocurrencia';
  static const cancelarSerieAgendaPath =
      '/api/AdministrarEventoAgenda/cancelar-serie';
  static const obtenerTiposEventoPath =
      '/api/AdministrarTipoEvento/obtener-todos';

  static const obtenerHabitosPath = '/api/AdministrarHabitoVida/obtener-todos';
  static const crearHabitoPath = '/api/AdministrarHabitoVida/crear';
  static const modificarHabitoPath = '/api/AdministrarHabitoVida/modificar';
  static const eliminarHabitoPath = '/api/AdministrarHabitoVida/eliminar';
  static const crearRealizacionHabitoPath =
      '/api/AdministrarHabitoVida/crear-realizacion';
  static const modificarRealizacionHabitoPath =
      '/api/AdministrarHabitoVida/modificar-realizacion';
  static const eliminarRealizacionHabitoPath =
      '/api/AdministrarHabitoVida/eliminar-realizacion';
  static const obtenerTiposHabitosVidaPath =
      '/api/AdministrarTipoHabitoVida/obtener-todos';

  static const obtenerEventosSaludPath =
      '/api/AdministrarEventoSalud/obtener-todos';
  static const crearEventoSaludPath = '/api/AdministrarEventoSalud/crear';
  static const eliminarEventoSaludPath = '/api/AdministrarEventoSalud/eliminar';
  static const agregarNotaEventoSaludPath =
      '/api/AdministrarEventoSalud/agregar-nota';
  static const modificarNotaEventoSaludPath =
      '/api/AdministrarEventoSalud/modificar-nota';
  static const eliminarNotaEventoSaludPath =
      '/api/AdministrarEventoSalud/eliminar-nota';

  static const obtenerAnimoHoyPath =
      '/api/AdministrarPersonaEstadoAnimo/obtener-animo-hoy';
  static const obtenerAnimoPorFechasPath =
      '/api/AdministrarPersonaEstadoAnimo/obtener-por-fechas';
  static const registrarAnimoPath =
      '/api/AdministrarPersonaEstadoAnimo/registrar';

  static const obtenerLineaTiempoSaludPath =
      '/api/LineaTiempoSalud/obtener-por-fechas';

  static const obtenerAlertasBienestarPath = '/api/AlertaBienestar/obtener';

  static const obtenerResumenSaludPath = '/api/ResumenSalud/obtener';

  static const obtenerResumenInteligentePath = '/api/ResumenDiario/generar';

  static const registrarDispositivoPath = '/api/Dispositivo/registrar';
  static const eliminarDispositivoPath = '/api/Dispositivo/eliminar';

  static const activarEmergenciaPath = '/api/Emergencia/activar';
  static const obtenerEmergenciasPath = '/api/Emergencia/obtener';

  static const obtenerFichaSaludPath = '/api/AdministrarFichaSalud/obtener';
  static const crearFichaSaludPath = '/api/AdministrarFichaSalud/crear';
  static const modificarFichaSaludPath = '/api/AdministrarFichaSalud/modificar';
}
