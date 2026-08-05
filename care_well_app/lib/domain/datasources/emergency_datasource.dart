import '../entities/entities.dart';

/// Interfaz de datasource para el módulo de emergencias.
abstract class EmergencyDatasource {
  /// Activa una nueva emergencia para la persona con [personaId].
  ///
  /// No retorna la emergencia creada: el registro queda del lado del servidor y
  /// el aviso al equipo de cuidado lo envía el backend.
  Future<void> activarEmergencia({required int personaId, String? descripcion});

  /// Retorna las últimas [cantidad] emergencias de la persona con [personaId],
  /// de la más reciente a la más antigua.
  Future<List<Emergencia>> getEmergenciasByPersona(
    int personaId, {
    int cantidad = 20,
  });
}
