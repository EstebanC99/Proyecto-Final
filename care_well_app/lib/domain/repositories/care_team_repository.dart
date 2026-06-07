import '../entities/entities.dart';

/// Contrato de repositorio para el equipo de cuidado.
abstract class CareTeamRepository {
  // ─── Asignaciones ────────────────────────────────────────────────────────────

  /// Retorna las asignaciones activas de la persona cuidada con [personaCuidadaId].
  Future<List<AsignacionCuidado>> getAsignacionesByPersonaCuidada(
    String personaCuidadaId,
  );

  /// Crea una nueva asignación de cuidado.
  Future<AsignacionCuidado> crearAsignacion(AsignacionCuidado asignacion);

  /// Actualiza el estado o rol de una asignación.
  Future<AsignacionCuidado> actualizarAsignacion(AsignacionCuidado asignacion);

  /// Elimina la asignación con [asignacionId].
  Future<void> eliminarAsignacion(String asignacionId);

  /// Retorna las asignaciones donde el colaborador tiene [colaboradorId].
  Future<List<AsignacionCuidado>> getAsignacionesByColaborador(
    String colaboradorId,
  );

  // ─── Roles y permisos ────────────────────────────────────────────────────────

  /// Retorna los roles disponibles en el sistema.
  Future<List<Rol>> getRoles();

  /// Retorna el [Rol] con el [rolId] dado.
  Future<Rol> getRolById(String rolId);
}
