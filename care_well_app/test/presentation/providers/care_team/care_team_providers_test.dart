import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/domain/repositories/repositories.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../_fakes/test_fixtures.dart';

// ─── Fixtures ─────────────────────────────────────────────────────────────────

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

final _personaCarlos = Persona(
  id: 3,
  nombre: 'Carlos',
  apellido: 'Pérez',
  documento: '30000003',
  fechaNacimiento: DateTime(1985, 3, 15),
  email: 'carlos@test.com',
);

AsignacionCuidado _asignacionMaria() => AsignacionCuidado(
  id: 401,
  personaCuidada: _personaAlicia,
  colaborador: _personaMaria,
  rol: rolCuidadoResponsable,
  estado: estadoAsignacionActiva,
  fechaAlta: DateTime(2024, 1, 8),
);

AsignacionCuidado _asignacionCarlos() => AsignacionCuidado(
  id: 402,
  personaCuidada: _personaAlicia,
  colaborador: _personaCarlos,
  rol: rolCuidadoResponsable,
  estado: estadoAsignacionActiva,
  fechaAlta: DateTime(2024, 1, 10),
);

/// Asignación de María (usuario logueado) como Responsable de Alicia, con el
/// permiso [PermisosCuidadoConst.administrarEquipo] habilitado.
AsignacionCuidado _asignacionMariaConAdministrarEquipo() => AsignacionCuidado(
  id: 401,
  personaCuidada: _personaAlicia,
  colaborador: _personaMaria,
  rol: rolCuidadoResponsable,
  estado: estadoAsignacionActiva,
  fechaAlta: DateTime(2024, 1, 8),
  permisos: const [
    PermisoCuidado(
      id: PermisosCuidadoConst.administrarEquipo,
      descripcion: 'Administrar equipo de cuidado',
    ),
  ],
);

// ─── Fakes ────────────────────────────────────────────────────────────────────

class _FakePersonaRepository implements PersonaRepository {
  final List<Persona> _personas;

  _FakePersonaRepository(List<Persona> personas)
    : _personas = List.from(personas);

  @override
  Future<Persona> getById(int id) async => _personas.firstWhere(
    (p) => p.id == id,
    orElse: () => throw Exception('Persona no encontrada: $id'),
  );

  @override
  Future<List<Persona>> getDependientesByUsuario(int usuarioId) async => [];

  @override
  Future<Persona> crear(Persona persona) async {
    final nueva = persona.copyWith(id: 9999);
    _personas.add(nueva);
    return nueva;
  }

  @override
  Future<Persona> actualizar(Persona persona) async {
    final idx = _personas.indexWhere((p) => p.id == persona.id);
    if (idx >= 0) _personas[idx] = persona;
    return persona;
  }

  @override
  Future<void> eliminar(int id) async {
    _personas.removeWhere((p) => p.id == id);
  }
}

/// Fake de [AsignacionCuidadoRepository] que simula el endpoint que devuelve
/// las asignaciones del usuario logueado (María, id=1).
class _FakeAsignacionCuidadoRepository implements AsignacionCuidadoRepository {
  final List<AsignacionCuidado> _asignaciones;

  _FakeAsignacionCuidadoRepository(List<AsignacionCuidado> asignaciones)
    : _asignaciones = List.from(asignaciones);

  @override
  Future<List<AsignacionCuidado>> obtenerAsignacionesUsuarioLogueado() async =>
      // El usuario demo (María, id=1) es el colaborador de sus asignaciones.
      _asignaciones.where((a) => a.colaborador.id == 1).toList();

  @override
  Future<void> crearPersonaCargo({
    required String nombre,
    required String apellido,
    required String documento,
    required DateTime fechaNacimiento,
    String? email,
    String? telefono,
    List<int> permisosCuidadoIds = const [],
  }) async {}

  @override
  Future<Persona> modificarPersonaCargo(int asignacionId, Persona persona) =>
      throw UnimplementedError();

  @override
  Future<void> modificarPermisosAsignacion({
    required int asignacionId,
    required List<PermisoCuidado> permisosSeleccionados,
  }) async {}

  @override
  Future<void> eliminarAsignacion(int asignacionId) async {
    final idx = _asignaciones.indexWhere((a) => a.id == asignacionId);
    if (idx < 0) throw Exception('Asignación no encontrada: $asignacionId');
    _asignaciones.removeAt(idx);
  }

  @override
  Future<void> activarAsignacion(int asignacionId) =>
      throw UnimplementedError();

  @override
  Future<void> reactivarAsignacion(int asignacionId) =>
      throw UnimplementedError();

  @override
  Future<List<AsignacionCuidado>> obtenerAsignacionesPorPersona(
    int personaCuidadaId,
  ) async => _asignaciones
      .where((a) => a.personaCuidada.id == personaCuidadaId)
      .toList();

  @override
  Future<void> asignarPersonaEquipoCuidado({
    required int personaCuidadaId,
    required String colaboradorEmail,
    required int rolCuidadoId,
    required List<int> permisosCuidadoIds,
  }) => throw UnimplementedError();
}

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
    if (idx < 0) throw Exception('Asignación no encontrada: ${a.id}');
    _asignaciones[idx] = a;
    return a;
  }

  @override
  Future<void> eliminarAsignacion(int id) async {
    final idx = _asignaciones.indexWhere((a) => a.id == id);
    if (idx < 0) throw Exception('Asignación no encontrada: $id');
    _asignaciones.removeAt(idx);
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
  final asigs = asignaciones ?? [_asignacionMaria(), _asignacionCarlos()];
  final pers = personas ?? [_personaMaria, _personaAlicia, _personaCarlos];

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
  group('personaVisualizacionSeleccionadaProvider', () {
    test(
      'retorna la persona donde el usuario es Responsable cuando se la selecciona',
      () async {
        final container = _buildContainer();
        addTearDown(container.dispose);

        // Seleccionar explícitamente a la persona a cargo (Alicia).
        container
                .read(personaVisualizacionSeleccionadaIdProvider.notifier)
                .state =
            _personaAlicia.id;

        final persona = await container.read(
          personaVisualizacionSeleccionadaProvider.future,
        );

        expect(persona, isNotNull);
        expect(persona!.id, _personaAlicia.id);
      },
    );

    test(
      'retorna null si el usuario no tiene personas como Responsable ni Cuidador',
      () async {
        final container = _buildContainer(asignaciones: []);
        addTearDown(container.dispose);

        // Sin asignaciones: solo queda el propio usuario → retorna personaMaria.
        final persona = await container.read(
          personaVisualizacionSeleccionadaProvider.future,
        );

        // El propio usuario es la única opción disponible → no es null.
        expect(persona, isNotNull);
        expect(persona!.id, _personaMaria.id);
      },
    );

    test(
      'retorna la persona cuyo ID fue seleccionado explícitamente',
      () async {
        final container = _buildContainer();
        addTearDown(container.dispose);

        // Seleccionar al propio usuario (María) explícitamente.
        container
                .read(personaVisualizacionSeleccionadaIdProvider.notifier)
                .state =
            _personaMaria.id;

        final persona = await container.read(
          personaVisualizacionSeleccionadaProvider.future,
        );

        expect(persona, isNotNull);
        expect(persona!.id, _personaMaria.id);
      },
    );

    test(
      'cae a opciones.first cuando selectedId no existe en la lista',
      () async {
        final container = _buildContainer();
        addTearDown(container.dispose);

        // ID inexistente: debe volver a opciones.first (María, el propio usuario).
        container
                .read(personaVisualizacionSeleccionadaIdProvider.notifier)
                .state =
            99999;

        final persona = await container.read(
          personaVisualizacionSeleccionadaProvider.future,
        );

        expect(persona, isNotNull);
        // opciones.first es siempre el propio usuario (María).
        expect(persona!.id, _personaMaria.id);
      },
    );
  });

  group('personasSeleccionablesProvider', () {
    test(
      'incluye al propio usuario como primera opción con rol propio',
      () async {
        final container = _buildContainer();
        addTearDown(container.dispose);

        final opciones = await container.read(
          personasSeleccionablesProvider.future,
        );

        expect(opciones, isNotEmpty);
        expect(opciones.first.persona.id, _personaMaria.id);
        expect(opciones.first.rol, PersonaContextRol.propio);
      },
    );

    test('incluye a las personas donde el usuario es Responsable', () async {
      final container = _buildContainer();
      addTearDown(container.dispose);

      final opciones = await container.read(
        personasSeleccionablesProvider.future,
      );

      final responsable = opciones.where(
        (o) => o.rol == PersonaContextRol.responsable,
      );
      expect(responsable, isNotEmpty);
      expect(responsable.first.persona.id, _personaAlicia.id);
    });

    test('retorna solo el propio usuario cuando no hay asignaciones', () async {
      final container = _buildContainer(asignaciones: []);
      addTearDown(container.dispose);

      final opciones = await container.read(
        personasSeleccionablesProvider.future,
      );

      expect(opciones.length, 1);
      expect(opciones.first.rol, PersonaContextRol.propio);
    });

    test(
      'excluye personas con asignación pendiente (invitación no aceptada)',
      () async {
        // María (usuario logueado) es Responsable de Alicia, pero la
        // asignación todavía está en estado pendiente.
        final asignacionPendiente = AsignacionCuidado(
          id: 403,
          personaCuidada: _personaAlicia,
          colaborador: _personaMaria,
          rol: rolCuidadoResponsable,
          estado: estadoAsignacionPendiente,
          fechaAlta: DateTime(2024, 1, 12),
        );

        final container = _buildContainer(
          asignaciones: [asignacionPendiente],
          personas: [_personaMaria, _personaAlicia],
        );
        addTearDown(container.dispose);

        final opciones = await container.read(
          personasSeleccionablesProvider.future,
        );

        // Alicia no debe aparecer porque su asignación no está activa.
        expect(opciones.any((o) => o.persona.id == _personaAlicia.id), isFalse);
        // Solo queda el propio usuario.
        expect(opciones.length, 1);
        expect(opciones.first.persona.id, _personaMaria.id);
        expect(opciones.first.rol, PersonaContextRol.propio);
      },
    );
  });

  group('asignacionesPorPersonaCuidadaProvider', () {
    test('retorna las asignaciones de la persona cuidada', () async {
      final container = _buildContainer();
      addTearDown(container.dispose);

      final asignaciones = await container.read(
        asignacionesPorPersonaCuidadaProvider(_personaAlicia.id).future,
      );

      expect(asignaciones, isNotEmpty);
      expect(
        asignaciones.every((a) => a.personaCuidada.id == _personaAlicia.id),
        isTrue,
      );
    });

    test('retorna lista vacía para ID de persona inexistente', () async {
      final container = _buildContainer();
      addTearDown(container.dispose);

      final asignaciones = await container.read(
        asignacionesPorPersonaCuidadaProvider(99999).future,
      );

      expect(asignaciones, isEmpty);
    });
  });

  group('asignacionPersonaSeleccionadaPorIdProvider', () {
    test('retorna la asignación correcta por ID', () async {
      final container = _buildContainer();
      addTearDown(container.dispose);

      // Seleccionar a la persona a cargo (Alicia) como contexto.
      container
              .read(personaVisualizacionSeleccionadaIdProvider.notifier)
              .state =
          _personaAlicia.id;

      final asignacion = await container.read(
        asignacionPersonaSeleccionadaPorIdProvider(402).future,
      );

      expect(asignacion, isNotNull);
      expect(asignacion!.id, 402);
    });

    test('retorna null para ID de asignación inexistente', () async {
      final container = _buildContainer();
      addTearDown(container.dispose);

      final asignacion = await container.read(
        asignacionPersonaSeleccionadaPorIdProvider(99999).future,
      );

      expect(asignacion, isNull);
    });
  });

  group('availablePermisosProvider', () {
    test('retorna 7 permisos disponibles (uno por PermisosCuidadoConst)', () {
      final container = _buildContainer();
      addTearDown(container.dispose);

      final permisos = container.read(availablePermisosProvider);

      // Los 7 permisos definidos en PermisosCuidadoConst.
      expect(permisos.length, 7);
      expect(
        permisos.any((p) => p.id == PermisosCuidadoConst.verFichaSalud),
        isTrue,
      );
    });
  });

  group('esContextoPropioProvider', () {
    test(
      'retorna true cuando selectedPersonaId coincide con el id del usuario',
      () async {
        final container = _buildContainer();
        addTearDown(container.dispose);

        // Seleccionar explícitamente a María (el propio usuario).
        container
                .read(personaVisualizacionSeleccionadaIdProvider.notifier)
                .state =
            _personaMaria.id;

        final esPropio = await container.read(esContextoPropioProvider.future);
        expect(esPropio, isTrue);
      },
    );

    test(
      'retorna false cuando el contexto es una persona ajena (Alicia)',
      () async {
        final container = _buildContainer();
        addTearDown(container.dispose);

        // Seleccionar a la persona a cargo (Alicia) como contexto.
        container
                .read(personaVisualizacionSeleccionadaIdProvider.notifier)
                .state =
            _personaAlicia.id;

        final esPropio = await container.read(esContextoPropioProvider.future);
        expect(esPropio, isFalse);
      },
    );

    test('retorna false cuando no hay usuario autenticado', () async {
      final container = ProviderContainer(
        overrides: [
          authStateProvider.overrideWith(
            (ref) =>
                AuthNotifier(ref.watch(authRepositoryProvider))
                  ..state = const AsyncValue.data(null),
          ),
          personaRepositoryProvider.overrideWithValue(
            _FakePersonaRepository([_personaMaria, _personaAlicia]),
          ),
          asignacionCuidadoRepositoryProvider.overrideWithValue(
            _FakeAsignacionCuidadoRepository([]),
          ),
          careTeamRepositoryProvider.overrideWithValue(
            _FakeCareTeamRepository([]),
          ),
        ],
      );
      addTearDown(container.dispose);

      final esPropio = await container.read(esContextoPropioProvider.future);
      expect(esPropio, isFalse);
    });
  });

  group('esResponsableProvider', () {
    test(
      'retorna true si el usuario es Responsable de la persona de contexto',
      () async {
        final container = _buildContainer();
        addTearDown(container.dispose);

        final esResponsable = await container.read(
          esResponsablePersonaSeleccionadaProvider.future,
        );

        expect(esResponsable, isTrue);
      },
    );
  });

  group('puedeAdministrarEquipoProvider', () {
    test(
      'retorna true cuando la asignación propia activa incluye administrarEquipo',
      () async {
        // María (usuario logueado) es Responsable de Alicia (contexto default)
        // y su asignación incluye el permiso administrarEquipo.
        final container = _buildContainer(
          asignaciones: [
            _asignacionMariaConAdministrarEquipo(),
            _asignacionCarlos(),
          ],
        );
        addTearDown(container.dispose);

        final puede = await container.read(
          puedeAdministrarEquipoProvider.future,
        );

        expect(puede, isTrue);
      },
    );

    test(
      'retorna false cuando la asignación propia no incluye administrarEquipo',
      () async {
        // Asignación default de María (sin permisos poblados).
        final container = _buildContainer();
        addTearDown(container.dispose);

        // Seleccionar a la persona a cargo (Alicia) como contexto.
        container
                .read(personaVisualizacionSeleccionadaIdProvider.notifier)
                .state =
            _personaAlicia.id;

        final puede = await container.read(
          puedeAdministrarEquipoProvider.future,
        );

        expect(puede, isFalse);
      },
    );

    test('retorna false cuando no hay usuario autenticado', () async {
      final container = ProviderContainer(
        overrides: [
          authStateProvider.overrideWith(
            (ref) =>
                AuthNotifier(ref.watch(authRepositoryProvider))
                  ..state = const AsyncValue.data(null),
          ),
          personaRepositoryProvider.overrideWithValue(
            _FakePersonaRepository([_personaMaria, _personaAlicia]),
          ),
          asignacionCuidadoRepositoryProvider.overrideWithValue(
            _FakeAsignacionCuidadoRepository([]),
          ),
          careTeamRepositoryProvider.overrideWithValue(
            _FakeCareTeamRepository([]),
          ),
        ],
      );
      addTearDown(container.dispose);

      final puede = await container.read(puedeAdministrarEquipoProvider.future);

      expect(puede, isFalse);
    });
  });

  group('actualizarPermisosProvider', () {
    test('actualiza los permisos de la asignación correctamente', () async {
      final container = _buildContainer();
      addTearDown(container.dispose);

      final actualizarFn = container.read(actualizarPermisosProvider);

      await expectLater(
        actualizarFn(
          asignacion: _asignacionCarlos(),
          permisosActivos: [
            PermisoCuidado(
              id: PermisosCuidadoConst.verFichaSalud,
              descripcion: 'Ver ficha de salud',
            ),
          ],
        ),
        completes,
      );
    });
  });

  group('eliminarAsignacionProvider', () {
    test('elimina la asignación correctamente', () async {
      final container = _buildContainer();
      addTearDown(container.dispose);

      final eliminarFn = container.read(eliminarAsignacionProvider);

      await expectLater(eliminarFn(asignacion: _asignacionCarlos()), completes);
    });

    test('lanza excepción si la asignación no existe', () async {
      final container = _buildContainer();
      addTearDown(container.dispose);

      final eliminarFn = container.read(eliminarAsignacionProvider);

      final inexistente = AsignacionCuidado(
        id: 99999,
        personaCuidada: _personaAlicia,
        colaborador: _personaMaria,
        rol: rolCuidadoResponsable,
        estado: estadoAsignacionActiva,
        fechaAlta: DateTime(2024, 1, 1),
      );

      await expectLater(eliminarFn(asignacion: inexistente), throwsException);
    });
  });
}
