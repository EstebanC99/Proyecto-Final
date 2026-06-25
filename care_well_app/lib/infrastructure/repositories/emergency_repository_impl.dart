import '../../domain/datasources/datasources.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';

/// Implementación de [EmergencyRepository] que delega al [EmergencyDatasource] inyectado.
class EmergencyRepositoryImpl implements EmergencyRepository {
  final EmergencyDatasource _datasource;

  const EmergencyRepositoryImpl(this._datasource);

  @override
  Future<Emergencia> activarEmergencia({
    required int personaId,
    String? descripcion,
  }) => _datasource.activarEmergencia(
    personaId: personaId,
    descripcion: descripcion,
  );

  @override
  Future<List<Emergencia>> getEmergenciasByPersona(int personaId) =>
      _datasource.getEmergenciasByPersona(personaId);

  @override
  Future<Emergencia> marcarAtendida(int emergenciaId) =>
      _datasource.marcarAtendida(emergenciaId);
}
