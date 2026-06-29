class ApiConfig {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://<tu-url-dev-tunnel>.devtunnels.ms',
  );

  static const connectTimeout = Duration(seconds: 15);
  static const receiveTimeout = Duration(seconds: 20);

  static const loginPath = '/api/Authorization/login';
  static const refreshPath = '/api/Authorization/refresh-token';

  static const cuentaPath = '/api/Cuenta/crear';

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
}
