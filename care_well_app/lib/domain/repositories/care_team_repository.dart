import 'package:care_well_app/domain/entities/entities.dart';

abstract class CareTeamRepository {
  Future<List<AsignacionCuidado>> getAsignacionesByPersonaCuidada(
    int personaCuidadaId,
  );

  Future<AsignacionCuidado> crearAsignacion(AsignacionCuidado asignacion);

  Future<AsignacionCuidado> actualizarAsignacion(AsignacionCuidado asignacion);

  Future<void> eliminarAsignacion(int asignacionId);

  Future<List<AsignacionCuidado>> getAsignacionesByColaborador(
    int colaboradorId,
  );

  Future<List<RolCuidado>> getRoles();

  Future<RolCuidado> getRolById(int rolId);
}
