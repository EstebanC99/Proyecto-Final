import '../entities/entities.dart';

/// Contrato de repositorio para el módulo de emergencias.
abstract class EmergencyRepository {
  /// Activa una nueva emergencia para la persona con [personaId].
  Future<Emergencia> activarEmergencia({
    required String personaId,
    String? descripcion,
  });

  /// Retorna el historial de emergencias de la persona con [personaId].
  Future<List<Emergencia>> getEmergenciasByPersona(String personaId);

  /// Marca la emergencia con [emergenciaId] como atendida.
  Future<Emergencia> marcarAtendida(String emergenciaId);
}
