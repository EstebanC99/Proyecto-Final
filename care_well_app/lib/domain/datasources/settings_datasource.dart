import '../entities/entities.dart';

/// Interfaz de datasource para configuración de usuario y términos.
abstract class SettingsDatasource {
  /// Retorna la [Configuracion] del usuario con [usuarioId].
  /// Si no existe, retorna configuración por defecto.
  Future<Configuracion> getConfiguracion(int usuarioId);

  /// Guarda (crea o actualiza) la [Configuracion] del usuario.
  Future<Configuracion> guardarConfiguracion(Configuracion configuracion);

  /// Retorna el historial de aceptaciones de términos del usuario.
  Future<List<AceptacionTerminos>> getAceptaciones(int usuarioId);

  /// Registra la aceptación de una nueva versión de los Términos y Condiciones.
  Future<AceptacionTerminos> aceptarTerminos({
    required int usuarioId,
    required String version,
  });
}
