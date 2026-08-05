import '../entities/entities.dart';

/// Contrato de repositorio para el módulo de emergencias.
abstract class EmergencyRepository {
  /// Activa una nueva emergencia para la persona con [personaId].
  Future<void> activarEmergencia({required int personaId, String? descripcion});

  /// Retorna las últimas [cantidad] emergencias de la persona con [personaId].
  Future<List<Emergencia>> getEmergenciasByPersona(
    int personaId, {
    int cantidad = 20,
  });
}
