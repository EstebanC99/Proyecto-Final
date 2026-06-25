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
      '/api/AdministrarEquipoCuidado/crear-persona-cargo';
  static const obtenerMisAsignacionesPath =
      '/api/AdministrarEquipoCuidado/obtener-mis-asignaciones';
}
