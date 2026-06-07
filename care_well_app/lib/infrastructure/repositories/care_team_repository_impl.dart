import '../../domain/datasources/datasources.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';

/// Implementación de [CareTeamRepository] que delega al [CareTeamDatasource] inyectado.
class CareTeamRepositoryImpl implements CareTeamRepository {
  final CareTeamDatasource _datasource;

  const CareTeamRepositoryImpl(this._datasource);

  @override
  Future<List<AsignacionCuidado>> getAsignacionesByPersonaCuidada(
    String personaCuidadaId,
  ) => _datasource.getAsignacionesByPersonaCuidada(personaCuidadaId);

  @override
  Future<AsignacionCuidado> crearAsignacion(AsignacionCuidado asignacion) =>
      _datasource.crearAsignacion(asignacion);

  @override
  Future<AsignacionCuidado> actualizarAsignacion(
    AsignacionCuidado asignacion,
  ) => _datasource.actualizarAsignacion(asignacion);

  @override
  Future<void> eliminarAsignacion(String asignacionId) =>
      _datasource.eliminarAsignacion(asignacionId);

  @override
  Future<List<AsignacionCuidado>> getAsignacionesByColaborador(
    String colaboradorId,
  ) => _datasource.getAsignacionesByColaborador(colaboradorId);

  @override
  Future<List<Rol>> getRoles() => _datasource.getRoles();

  @override
  Future<Rol> getRolById(String rolId) => _datasource.getRolById(rolId);
}
