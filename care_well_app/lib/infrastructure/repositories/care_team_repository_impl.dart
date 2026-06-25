import '../../domain/datasources/datasources.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';

/// Implementación de [CareTeamRepository] que delega al [CareTeamDatasource] inyectado.
class CareTeamRepositoryImpl implements CareTeamRepository {
  final CareTeamDatasource _datasource;

  const CareTeamRepositoryImpl(this._datasource);

  @override
  Future<List<AsignacionCuidado>> getAsignacionesByPersonaCuidada(
    int personaCuidadaId,
  ) => _datasource.getAsignacionesByPersonaCuidada(personaCuidadaId);

  @override
  Future<AsignacionCuidado> crearAsignacion(AsignacionCuidado asignacion) =>
      _datasource.crearAsignacion(asignacion);

  @override
  Future<AsignacionCuidado> actualizarAsignacion(
    AsignacionCuidado asignacion,
  ) => _datasource.actualizarAsignacion(asignacion);

  @override
  Future<void> eliminarAsignacion(int asignacionId) =>
      _datasource.eliminarAsignacion(asignacionId);

  @override
  Future<List<AsignacionCuidado>> getAsignacionesByColaborador(
    int colaboradorId,
  ) => _datasource.getAsignacionesByColaborador(colaboradorId);

  @override
  Future<List<RolCuidado>> getRoles() => _datasource.getRoles();

  @override
  Future<RolCuidado> getRolById(int rolId) => _datasource.getRolById(rolId);
}
