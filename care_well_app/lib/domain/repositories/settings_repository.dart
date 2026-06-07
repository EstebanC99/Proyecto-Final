import '../entities/entities.dart';

/// Contrato de repositorio para configuración de usuario y términos.
abstract class SettingsRepository {
  /// Retorna la [Configuracion] del usuario con [usuarioId].
  Future<Configuracion> getConfiguracion(String usuarioId);

  /// Guarda (crea o actualiza) la [Configuracion] del usuario.
  Future<Configuracion> guardarConfiguracion(Configuracion configuracion);

  /// Retorna el historial de aceptaciones de términos del usuario.
  Future<List<AceptacionTerminos>> getAceptaciones(String usuarioId);

  /// Registra la aceptación de una nueva versión de los Términos y Condiciones.
  Future<AceptacionTerminos> aceptarTerminos({
    required String usuarioId,
    required String version,
  });
}
