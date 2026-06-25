import '../entities/entities.dart';

/// Contrato de repositorio para el equipo de cuidado.
abstract class CareTeamRepository {
  // ─── Asignaciones ────────────────────────────────────────────────────────────

  /// Retorna las asignaciones activas de la persona cuidada con [personaCuidadaId].
  Future<List<AsignacionCuidado>> getAsignacionesByPersonaCuidada(
    int personaCuidadaId,
  );

  /// Crea una nueva asignación de cuidado.
  Future<AsignacionCuidado> crearAsignacion(AsignacionCuidado asignacion);

  /// Actualiza el estado o rol de una asignación.
  Future<AsignacionCuidado> actualizarAsignacion(AsignacionCuidado asignacion);

  /// Elimina la asignación con [asignacionId].
  Future<void> eliminarAsignacion(int asignacionId);

  /// Retorna las asignaciones donde el colaborador tiene [colaboradorId].
  Future<List<AsignacionCuidado>> getAsignacionesByColaborador(
    int colaboradorId,
  );

  // ─── Roles ───────────────────────────────────────────────────────────────────

  /// Retorna los roles disponibles en el sistema.
  Future<List<RolCuidado>> getRoles();

  /// Retorna el [RolCuidado] con el [rolId] dado.
  Future<RolCuidado> getRolById(int rolId);
}
