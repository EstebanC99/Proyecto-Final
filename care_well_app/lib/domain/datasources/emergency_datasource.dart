import '../entities/entities.dart';

/// Interfaz de datasource para el módulo de emergencias.
abstract class EmergencyDatasource {
  /// Activa una nueva emergencia para la persona con [personaId].
  ///
  /// Retorna la [Emergencia] creada con su id generado.
  Future<Emergencia> activarEmergencia({
    required int personaId,
    String? descripcion,
  });

  /// Retorna el historial de emergencias de la persona con [personaId].
  Future<List<Emergencia>> getEmergenciasByPersona(int personaId);

  /// Marca la emergencia con [emergenciaId] como atendida.
  Future<Emergencia> marcarAtendida(int emergenciaId);
}
