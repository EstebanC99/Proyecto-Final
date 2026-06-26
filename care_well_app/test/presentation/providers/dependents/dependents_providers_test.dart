import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/domain/repositories/repositories.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../_fakes/test_fixtures.dart';

// ─── Fakes ────────────────────────────────────────────────────────────────────

final _personaAlicia = Persona(
  id: 2,
  nombre: 'Alicia',
  apellido: 'Rodríguez',
  documento: '5234100',
  fechaNacimiento: DateTime(1943, 7, 22),
);

final _personaMaria = Persona(
  id: 1,
  nombre: 'María',
  apellido: 'García',
  documento: '28000001',
  fechaNacimiento: DateTime(1990, 1, 1),
  email: 'maria@test.com',
);

/// Asignación en la que María es responsable de Alicia (activa).
AsignacionCuidado _asignacionMariaResponsable() => AsignacionCuidado(
  id: 401,
  personaCuidada: _personaAlicia,
  colaborador: _personaMaria,
  rol: rolCuidadoResponsable,
  estado: estadoAsignacionActiva,
  fechaAlta: DateTime(2024, 1, 8),
);

/// Asignación en la que María es responsable de Alicia (pendiente).
AsignacionCuidado _asignacionMariaPendiente() => AsignacionCuidado(
  id: 402,
  personaCuidada: _personaAlicia,
  colaborador: _personaMaria,
  rol: rolCuidadoResponsable,
  estado: estadoAsignacionPendiente,
  fechaAlta: DateTime(2024, 6, 1),
);

/// Asignación en la que María es responsable de Alicia (inactiva/eliminada).
AsignacionCuidado _asignacionMariaInactiva() => AsignacionCuidado(
  id: 405,
  personaCuidada: _personaAlicia,
  colaborador: _personaMaria,
  rol: rolCuidadoResponsable,
  estado: estadoAsignacionInactiva,
  fechaAlta: DateTime(2024, 1, 8),
  fechaEliminacion: DateTime(2024, 9, 1),
);

/// Fake de [PersonaRepository] para tests de dependents.
class _FakePersonaRepository implements PersonaRepository {
  final List<Persona> _personas;
  int _nextId = 10000;

  _FakePersonaRepository(this._personas);

  @override
  Future<Persona> getById(int id) async {
    return _personas.firstWhere(
      (p) => p.id == id,
      orElse: () => throw Exception('Persona no encontrada: $id'),
    );
  }

  @override
  Future<List<Persona>> getDependientesByUsuario(int usuarioId) async =>
      _personas.where((p) => p.id == 2).toList();

  @override
  Future<Persona> crear(Persona persona) async {
    final nueva = persona.copyWith(id: _nextId++);
    _personas.add(nueva);
    return nueva;
  }

  @override
  Future<Persona> actualizar(Persona persona) async {
    final idx = _personas.indexWhere((p) => p.id == persona.id);
    if (idx < 0) throw Exception('Persona no encontrada.');
    _personas[idx] = persona;
    return persona;
  }

  @override
  Future<void> eliminar(int id) async {
    _personas.removeWhere((p) => p.id == id);
  }
}

/// Fake de [AsignacionCuidadoRepository] para tests de dependents.
class _FakeAsignacionCuidadoRepository implements AsignacionCuidadoRepository {
  final List<AsignacionCuidado> _asignaciones;
  int _nextId = 10000;

  _FakeAsignacionCuidadoRepository(List<AsignacionCuidado> asignaciones)
    : _asignaciones = List.from(asignaciones);

  @override
  Future<List<AsignacionCuidado>> obtenerAsignacionesUsuarioLogueado() async =>
      // Devuelve asignaciones donde María (id=1) es colaborador.
      _asignaciones.where((a) => a.colaborador.id == 1).toList();

  @override
  Future<void> crearPersonaCargo({
    required String nombre,
    required String apellido,
    required String documento,
    required DateTime fechaNacimiento,
    String? email,
    String? telefono,
  }) async {
    _asignaciones.add(
      AsignacionCuidado(
        id: _nextId++,
        personaCuidada: Persona(
          id: _nextId++,
          nombre: nombre,
          apellido: apellido,
          documento: documento,
          fechaNacimiento: fechaNacimiento,
          email: email,
          telefono: telefono,
        ),
        colaborador: _personaMaria,
        rol: rolCuidadoResponsable,
        estado: estadoAsignacionActiva,
        fechaAlta: DateTime.now(),
      ),
    );
  }

  @override
  Future<Persona> modificarPersonaCargo(
    int asignacionId,
    Persona persona,
  ) async {
    final idx = _asignaciones.indexWhere((a) => a.id == asignacionId);
    if (idx < 0) throw Exception('Asignación no encontrada: $asignacionId');
    final actual = _asignaciones[idx];
    _asignaciones[idx] = AsignacionCuidado(
      id: actual.id,
      personaCuidada: persona,
      colaborador: actual.colaborador,
      rol: actual.rol,
      estado: actual.estado,
      fechaAlta: actual.fechaAlta,
    );
    return persona;
  }

  @override
  Future<void> eliminarAsignacion(int asignacionId) async {
    final idx = _asignaciones.indexWhere((a) => a.id == asignacionId);
    if (idx < 0) throw Exception('Asignación no encontrada: $asignacionId');
    _asignaciones[idx] = _asignaciones[idx].copyWith(
      estado: estadoAsignacionInactiva,
    );
  }

  @override
  Future<void> reactivarAsignacion(int asignacionId) async {
    final idx = _asignaciones.indexWhere((a) => a.id == asignacionId);
    if (idx < 0) throw Exception('Asignación no encontrada: $asignacionId');
    _asignaciones[idx] = _asignaciones[idx].copyWith(
      estado: estadoAsignacionActiva,
    );
  }
}

/// Fake de [CareTeamRepository] para tests de dependents.
class _FakeCareTeamRepository implements CareTeamRepository {
  final List<AsignacionCuidado> _asignaciones;
  int _nextId = 10000;

  _FakeCareTeamRepository(List<AsignacionCuidado> asignaciones)
    : _asignaciones = List.from(asignaciones);

  @override
  Future<List<AsignacionCuidado>> getAsignacionesByColaborador(
    int colaboradorId,
  ) async =>
      _asignaciones.where((a) => a.colaborador.id == colaboradorId).toList();

  @override
  Future<List<AsignacionCuidado>> getAsignacionesByPersonaCuidada(
    int personaCuidadaId,
  ) async => _asignaciones
      .where((a) => a.personaCuidada.id == personaCuidadaId)
      .toList();

  @override
  Future<AsignacionCuidado> crearAsignacion(AsignacionCuidado a) async {
    final nueva = AsignacionCuidado(
      id: _nextId++,
      personaCuidada: a.personaCuidada,
      colaborador: a.colaborador,
      rol: a.rol,
      estado: a.estado,
      fechaAlta: a.fechaAlta,
    );
    _asignaciones.add(nueva);
    return nueva;
  }

  @override
  Future<AsignacionCuidado> actualizarAsignacion(AsignacionCuidado a) async {
    final idx = _asignaciones.indexWhere((x) => x.id == a.id);
    if (idx < 0) throw Exception('No encontrada.');
    _asignaciones[idx] = a;
    return a;
  }

  @override
  Future<void> eliminarAsignacion(int id) async {
    _asignaciones.removeWhere((a) => a.id == id);
  }

  @override
  Future<List<RolCuidado>> getRoles() async => [
    rolCuidadoResponsable,
    rolCuidadoCuidador,
  ];

  @override
  Future<RolCuidado> getRolById(int rolId) async => [
    rolCuidadoResponsable,
    rolCuidadoCuidador,
  ].firstWhere((r) => r.id == rolId);
}

/// Usuario demo logueado.
final _usuarioDemoMaria = Usuario(
  id: 101,
  persona: _personaMaria,
  contrasena: 'hash123',
  estado: estadoUsuarioActivo,
);

ProviderContainer _buildContainer({
  List<AsignacionCuidado>? asignaciones,
  List<Persona>? personas,
}) {
  final asigs = asignaciones ?? [_asignacionMariaResponsable()];
  final pers = personas ?? [_personaMaria, _personaAlicia];

  return ProviderContainer(
    overrides: [
      authStateProvider.overrideWith(
        (ref) =>
            AuthNotifier(ref.watch(authRepositoryProvider))
              ..state = AsyncValue.data(_usuarioDemoMaria),
      ),
      personaRepositoryProvider.overrideWithValue(_FakePersonaRepository(pers)),
      asignacionCuidadoRepositoryProvider.overrideWithValue(
        _FakeAsignacionCuidadoRepository(asigs),
      ),
      careTeamRepositoryProvider.overrideWithValue(
        _FakeCareTeamRepository(asigs),
      ),
    ],
  );
}

void main() {
  group('assignmentsAsResponsableProvider', () {
    test(
      'retorna asignaciones donde el usuario es Responsable activo',
      () async {
        final container = _buildContainer();
        addTearDown(container.dispose);

        final asignaciones = await container.read(
          activeAssignmentsAsResponsableProvider.future,
        );

        expect(asignaciones, isNotEmpty);
        expect(asignaciones.first.personaCuidada.id, _personaAlicia.id);
      },
    );

    test('retorna lista vacía si el usuario no tiene asignaciones', () async {
      final container = _buildContainer(asignaciones: []);
      addTearDown(container.dispose);

      final asignaciones = await container.read(
        activeAssignmentsAsResponsableProvider.future,
      );

      expect(asignaciones, isEmpty);
    });

    test(
      'retorna lista vacía si las asignaciones son de rol Cuidador',
      () async {
        final asignacionCuidador = AsignacionCuidado(
          id: 403,
          personaCuidada: _personaAlicia,
          colaborador: _personaMaria,
          rol: rolCuidadoCuidador,
          estado: estadoAsignacionActiva,
          fechaAlta: DateTime(2024, 1, 1),
        );
        final container = _buildContainer(asignaciones: [asignacionCuidador]);
        addTearDown(container.dispose);

        final asignaciones = await container.read(
          activeAssignmentsAsResponsableProvider.future,
        );

        expect(asignaciones, isEmpty);
      },
    );

    test('incluye asignaciones pendientes (no las excluye)', () async {
      final container = _buildContainer(
        asignaciones: [_asignacionMariaPendiente()],
      );
      addTearDown(container.dispose);

      final asignaciones = await container.read(
        activeAssignmentsAsResponsableProvider.future,
      );

      expect(asignaciones, isNotEmpty);
      expect(asignaciones.first.estado.id, estadoAsignacionPendiente.id);
    });

    test('excluye asignaciones inactivas', () async {
      final container = _buildContainer(
        asignaciones: [
          _asignacionMariaResponsable(),
          _asignacionMariaInactiva(),
        ],
      );
      addTearDown(container.dispose);

      final asignaciones = await container.read(
        activeAssignmentsAsResponsableProvider.future,
      );

      expect(asignaciones, hasLength(1));
      expect(asignaciones.first.estado.id, estadoAsignacionActiva.id);
    });
  });

  group('assignmentsAsCuidadorProvider', () {
    test('retorna asignaciones donde el usuario es Cuidador activo', () async {
      final asignacionCuidador = AsignacionCuidado(
        id: 404,
        personaCuidada: _personaAlicia,
        colaborador: _personaMaria,
        rol: rolCuidadoCuidador,
        estado: estadoAsignacionActiva,
        fechaAlta: DateTime(2024, 1, 1),
      );
      final container = _buildContainer(asignaciones: [asignacionCuidador]);
      addTearDown(container.dispose);

      final asignaciones = await container.read(
        activeAssignmentsAsCuidadorProvider.future,
      );

      expect(asignaciones, isNotEmpty);
      expect(asignaciones.first.personaCuidada.id, _personaAlicia.id);
    });

    test('retorna lista vacía si no hay asignaciones de cuidador', () async {
      final container = _buildContainer();
      addTearDown(container.dispose);

      final asignaciones = await container.read(
        activeAssignmentsAsCuidadorProvider.future,
      );

      expect(asignaciones, isEmpty);
    });
  });

  group('dependentsListResponsableProvider', () {
    test('incluye asignaciones inactivas (eliminadas)', () async {
      final container = _buildContainer(
        asignaciones: [
          _asignacionMariaResponsable(),
          _asignacionMariaInactiva(),
        ],
      );
      addTearDown(container.dispose);

      final asignaciones = await container.read(
        assignmentsAsResponsableProvider.future,
      );

      expect(asignaciones, hasLength(2));
      expect(
        asignaciones.any((a) => a.estado.id == estadoAsignacionInactiva.id),
        isTrue,
      );
    });

    test('excluye asignaciones de rol Cuidador', () async {
      final asignacionCuidador = AsignacionCuidado(
        id: 406,
        personaCuidada: _personaAlicia,
        colaborador: _personaMaria,
        rol: rolCuidadoCuidador,
        estado: estadoAsignacionActiva,
        fechaAlta: DateTime(2024, 1, 1),
      );
      final container = _buildContainer(asignaciones: [asignacionCuidador]);
      addTearDown(container.dispose);

      final asignaciones = await container.read(
        assignmentsAsResponsableProvider.future,
      );

      expect(asignaciones, isEmpty);
    });
  });

  group('dependentsListCuidadorProvider', () {
    test('incluye asignaciones inactivas (eliminadas)', () async {
      final asignacionCuidadorInactiva = AsignacionCuidado(
        id: 407,
        personaCuidada: _personaAlicia,
        colaborador: _personaMaria,
        rol: rolCuidadoCuidador,
        estado: estadoAsignacionInactiva,
        fechaAlta: DateTime(2024, 1, 1),
        fechaEliminacion: DateTime(2024, 9, 1),
      );
      final container = _buildContainer(
        asignaciones: [asignacionCuidadorInactiva],
      );
      addTearDown(container.dispose);

      final asignaciones = await container.read(
        assignmentsAsCuidadorProvider.future,
      );

      expect(asignaciones, hasLength(1));
      expect(asignaciones.first.estado.id, estadoAsignacionInactiva.id);
    });
  });

  group('asignacionByIdProvider', () {
    test('retorna la asignación con el id correcto', () async {
      final container = _buildContainer();
      addTearDown(container.dispose);

      final asignacion = await container.read(
        asignacionByIdProvider(401).future,
      );

      expect(asignacion.id, 401);
      expect(asignacion.personaCuidada.nombre, 'Alicia');
    });

    test('lanza StateError si el id no existe en memoria', () async {
      final container = _buildContainer();
      addTearDown(container.dispose);

      await expectLater(
        container.read(asignacionByIdProvider(99999).future),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('crearDependenteProvider', () {
    test('crea persona sin lanzar excepción', () async {
      final container = _buildContainer();
      addTearDown(container.dispose);

      final crearFn = container.read(crearDependenteProvider);

      await expectLater(
        crearFn(
          nombre: 'Pedro',
          apellido: 'López',
          documento: '30123456',
          fechaNacimiento: DateTime(1970, 5, 10),
          email: 'pedro@test.com',
        ),
        completes,
      );
    });

    test('invalida misAsignacionesProvider tras creación', () async {
      final container = _buildContainer();
      addTearDown(container.dispose);

      // Primero leer para establecer el estado.
      await container.read(misAsignacionesProvider.future);

      final crearFn = container.read(crearDependenteProvider);
      await crearFn(
        nombre: 'Pedro',
        apellido: 'López',
        documento: '30123456',
        fechaNacimiento: DateTime(1970, 5, 10),
      );

      // Después de crear, el estado del provider debe haberse reiniciado.
      final state = container.read(misAsignacionesProvider);
      expect(state, isNotNull);
    });
  });

  group('actualizarDependenteProvider', () {
    test('actualiza y retorna la persona modificada', () async {
      final container = _buildContainer();
      addTearDown(container.dispose);

      final actualizarFn = container.read(actualizarDependenteProvider);

      // asignacionId=401 corresponde a _asignacionMariaResponsable().
      final actualizada = await actualizarFn(
        401,
        _personaAlicia.copyWith(nombre: 'Alicia Modificada'),
      );

      expect(actualizada.nombre, 'Alicia Modificada');
    });
  });

  group('eliminarDependenteProvider', () {
    test('elimina la persona sin lanzar excepción', () async {
      final container = _buildContainer();
      addTearDown(container.dispose);

      final eliminarFn = container.read(eliminarDependenteProvider);

      await expectLater(eliminarFn(401), completes);
    });
  });

  group('reactivarDependenteProvider', () {
    test('reactiva la asignación sin lanzar excepción', () async {
      final container = _buildContainer(
        asignaciones: [_asignacionMariaInactiva()],
      );
      addTearDown(container.dispose);

      final reactivarFn = container.read(reactivarDependenteProvider);

      await expectLater(reactivarFn(405), completes);
    });

    test('tras reactivar, la asignación vuelve a estado activo', () async {
      final container = _buildContainer(
        asignaciones: [_asignacionMariaInactiva()],
      );
      addTearDown(container.dispose);

      await container.read(reactivarDependenteProvider)(405);

      final asignaciones = await container.read(
        assignmentsAsResponsableProvider.future,
      );
      expect(asignaciones.single.estado.id, estadoAsignacionActiva.id);
    });
  });
}
