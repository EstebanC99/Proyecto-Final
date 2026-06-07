import '../entities/entities.dart';

/// Interfaz de datasource para el equipo de cuidado.
abstract class CareTeamDatasource {
  // ─── Asignaciones ────────────────────────────────────────────────────────────

  /// Retorna todas las [AsignacionCuidado] asociadas a la persona cuidada.
  Future<List<AsignacionCuidado>> getAsignacionesByPersonaCuidada(
    String personaCuidadaId,
  );

  /// Crea una nueva asignación (invita a un colaborador).
  Future<AsignacionCuidado> crearAsignacion(AsignacionCuidado asignacion);

  /// Actualiza el estado o rol de una asignación existente.
  Future<AsignacionCuidado> actualizarAsignacion(AsignacionCuidado asignacion);

  /// Elimina (da de baja) la asignación con [asignacionId].
  Future<void> eliminarAsignacion(String asignacionId);

  /// Retorna todas las [AsignacionCuidado] donde el colaborador tiene [colaboradorId].
  Future<List<AsignacionCuidado>> getAsignacionesByColaborador(
    String colaboradorId,
  );

  // ─── Roles y permisos ────────────────────────────────────────────────────────

  /// Retorna todos los [Rol] disponibles en el sistema.
  Future<List<Rol>> getRoles();

  /// Retorna el [Rol] con el [rolId] dado, incluyendo sus [Permiso].
  Future<Rol> getRolById(String rolId);
}
