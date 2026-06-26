import '../../../domain/datasources/datasources.dart';
import '../../../domain/entities/entities.dart';
import 'demo_seed.dart';

/// Implementación demo (en memoria) de [AsignacionCuidadoDatasource].
///
/// Simula el endpoint `POST /api/AdministrarPersonasCargo/crear-persona-cargo`,
/// el endpoint `POST /api/AdministrarPersonasCargo/modificar-persona-cargo`
/// y el endpoint `GET /api/AdministrarPersonasCargo/obtener-mis-asignaciones`
/// sin necesidad de servidor.
class DemoAsignacionCuidadoDatasource implements AsignacionCuidadoDatasource {
  /// Lista mutable de asignaciones en la sesión demo.
  ///
  /// Se inicializa con las asignaciones del seed que involucran al usuario
  /// demo (María) como colaborador.
  final List<AsignacionCuidado> _asignaciones = [DemoSeed.asignacionMaria];

  int _nextPersonaId = 10000;
  int _nextAsignacionId = 10400;

  // ── crearPersonaCargo ─────────────────────────────────────────────────────

  /// Crea una [Persona] en memoria y la vincula al usuario demo como
  /// Responsable mediante una nueva [AsignacionCuidado].
  @override
  Future<void> crearPersonaCargo({
    required String nombre,
    required String apellido,
    required String documento,
    required DateTime fechaNacimiento,
    String? email,
    String? telefono,
    List<int> permisosCuidadoIds = const [],
  }) async {
    await Future.delayed(Duration.zero);

    final nuevaPersona = Persona(
      id: _nextPersonaId++,
      nombre: nombre,
      apellido: apellido,
      documento: documento,
      fechaNacimiento: fechaNacimiento,
      email: email,
      telefono: telefono,
    );

    final nuevaAsignacion = AsignacionCuidado(
      id: _nextAsignacionId++,
      personaCuidada: nuevaPersona,
      colaborador: DemoSeed.personaMaria,
      rol: DemoSeed.rolCuidadoResponsable,
      estado: DemoSeed.estadoAsignacionActiva,
      fechaAlta: DateTime.now(),
      permisos: DemoSeed.permisosResponsable,
    );

    _asignaciones.add(nuevaAsignacion);
  }

  // ── modificarPersonaCargo ─────────────────────────────────────────────────

  /// Actualiza la [Persona] cuidada dentro de la asignación con [asignacionId].
  ///
  /// Lanza [Exception] si la asignación no existe en memoria.
  @override
  Future<Persona> modificarPersonaCargo(
    int asignacionId,
    Persona persona,
  ) async {
    await Future.delayed(Duration.zero);

    final idx = _asignaciones.indexWhere((a) => a.id == asignacionId);
    if (idx < 0) {
      throw Exception('Asignación no encontrada en demo: $asignacionId');
    }

    final asignacionActual = _asignaciones[idx];
    _asignaciones[idx] = AsignacionCuidado(
      id: asignacionActual.id,
      personaCuidada: persona,
      colaborador: asignacionActual.colaborador,
      rol: asignacionActual.rol,
      estado: asignacionActual.estado,
      fechaAlta: asignacionActual.fechaAlta,
      permisos: asignacionActual.permisos,
    );

    return persona;
  }

  // ── obtenerAsignacionesUsuarioLogueado ────────────────────────────────────

  /// Retorna la lista de asignaciones del usuario demo.
  ///
  /// El backend ya filtra solo las activas; aquí se devuelve toda la lista
  /// (que en demo solo contiene activas).
  @override
  Future<List<AsignacionCuidado>> obtenerAsignacionesUsuarioLogueado() async {
    await Future.delayed(Duration.zero);
    return List.unmodifiable(_asignaciones);
  }
}
