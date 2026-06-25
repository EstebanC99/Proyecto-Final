import '../../../domain/datasources/datasources.dart';
import '../../../domain/entities/entities.dart';
import 'demo_seed.dart';

/// Implementación demo (en memoria) de [CareTeamDatasource].
class DemoCareTeamDatasource implements CareTeamDatasource {
  final List<RolCuidado> _roles = [
    DemoSeed.rolCuidadoResponsable,
    DemoSeed.rolCuidadoCuidador,
  ];

  final List<AsignacionCuidado> _asignaciones = [
    DemoSeed.asignacionCarlos,
    DemoSeed.asignacionLaura,
    DemoSeed.asignacionMaria,
  ];

  int _nextId = 10000;

  @override
  Future<List<AsignacionCuidado>> getAsignacionesByPersonaCuidada(
    int personaCuidadaId,
  ) async {
    await Future.delayed(Duration.zero);
    return _asignaciones
        .where((a) => a.personaCuidada.id == personaCuidadaId)
        .toList();
  }

  @override
  Future<List<AsignacionCuidado>> getAsignacionesByColaborador(
    int colaboradorId,
  ) async {
    await Future.delayed(Duration.zero);
    return _asignaciones
        .where((a) => a.personaColaborador.id == colaboradorId)
        .toList();
  }

  @override
  Future<AsignacionCuidado> crearAsignacion(
    AsignacionCuidado asignacion,
  ) async {
    await Future.delayed(Duration.zero);
    final nueva = AsignacionCuidado(
      id: _nextId++,
      personaCuidada: asignacion.personaCuidada,
      personaColaborador: asignacion.personaColaborador,
      rol: asignacion.rol,
      estado: asignacion.estado,
      fechaAlta: asignacion.fechaAlta,
    );
    _asignaciones.add(nueva);
    return nueva;
  }

  @override
  Future<AsignacionCuidado> actualizarAsignacion(
    AsignacionCuidado asignacion,
  ) async {
    await Future.delayed(Duration.zero);
    final idx = _asignaciones.indexWhere((a) => a.id == asignacion.id);
    if (idx < 0) throw Exception('Asignación no encontrada: ${asignacion.id}');
    _asignaciones[idx] = asignacion;
    return asignacion;
  }

  @override
  Future<void> eliminarAsignacion(int asignacionId) async {
    await Future.delayed(Duration.zero);
    final idx = _asignaciones.indexWhere((a) => a.id == asignacionId);
    if (idx < 0) throw Exception('Asignación no encontrada: $asignacionId');
    _asignaciones.removeAt(idx);
  }

  @override
  Future<List<RolCuidado>> getRoles() async {
    await Future.delayed(Duration.zero);
    return List.unmodifiable(_roles);
  }

  @override
  Future<RolCuidado> getRolById(int rolId) async {
    await Future.delayed(Duration.zero);
    final rol = _roles.where((r) => r.id == rolId).firstOrNull;
    if (rol == null) throw Exception('Rol no encontrado: $rolId');
    return rol;
  }
}
