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
  static const eliminarAsignacionPath =
      '/api/AdministrarPersonasCargo/eliminar-asignacion';
  static const reactivarAsignacionPath =
      '/api/AdministrarPersonasCargo/reactivar-asignacion';
}
