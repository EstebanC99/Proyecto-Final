import '../entities/entities.dart';

/// Interfaz de datasource para el equipo de cuidado.
abstract class CareTeamDatasource {
  // ─── Asignaciones ────────────────────────────────────────────────────────────

  /// Retorna todas las [AsignacionCuidado] asociadas a la persona cuidada.
  Future<List<AsignacionCuidado>> getAsignacionesByPersonaCuidada(
    int personaCuidadaId,
  );

  /// Crea una nueva asignación (invita a un colaborador).
  Future<AsignacionCuidado> crearAsignacion(AsignacionCuidado asignacion);

  /// Actualiza el estado o rol de una asignación existente.
  Future<AsignacionCuidado> actualizarAsignacion(AsignacionCuidado asignacion);

  /// Elimina (da de baja) la asignación con [asignacionId].
  Future<void> eliminarAsignacion(int asignacionId);

  /// Retorna todas las [AsignacionCuidado] donde el colaborador tiene [colaboradorId].
  Future<List<AsignacionCuidado>> getAsignacionesByColaborador(
    int colaboradorId,
  );

  // ─── Roles ───────────────────────────────────────────────────────────────────

  /// Retorna todos los [RolCuidado] disponibles en el sistema.
  Future<List<RolCuidado>> getRoles();

  /// Retorna el [RolCuidado] con el [rolId] dado.
  Future<RolCuidado> getRolById(int rolId);
}
