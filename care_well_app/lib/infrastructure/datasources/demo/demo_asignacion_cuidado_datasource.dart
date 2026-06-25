import '../../../domain/datasources/datasources.dart';
import '../../../domain/entities/entities.dart';
import 'demo_seed.dart';

/// Implementación demo (en memoria) de [AsignacionCuidadoDatasource].
///
/// Simula el endpoint `POST /api/AdministrarEquipoCuidado/crear-persona-cargo`
/// y el endpoint `GET /api/AdministrarEquipoCuidado/obtener-mis-asignaciones`
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
      personaColaborador: DemoSeed.personaMaria,
      rol: DemoSeed.rolCuidadoResponsable,
      estado: DemoSeed.estadoAsignacionActiva,
      fechaAlta: DateTime.now(),
      permisos: DemoSeed.permisosResponsable,
    );

    _asignaciones.add(nuevaAsignacion);
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
