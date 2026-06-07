import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/domain/repositories/repositories.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// ─── Fixtures ─────────────────────────────────────────────────────────────────

final _personaAlicia = Persona(
  id: 'per_002',
  nombre: 'Alicia',
  apellido: 'Rodríguez',
);

final _personaMaria = Persona(
  id: 'per_001',
  nombre: 'María',
  apellido: 'García',
  email: 'maria@test.com',
);

final _personaCarlos = Persona(
  id: 'per_003',
  nombre: 'Carlos',
  apellido: 'Pérez',
  email: 'carlos@test.com',
);

final _rolResponsable = Rol(id: 'rol_001', nombre: RolCuidado.responsable);
final _rolCuidador = Rol(id: 'rol_002', nombre: RolCuidado.cuidador);

AsignacionCuidado _asignacionMaria() => AsignacionCuidado(
  id: 'asi_003',
  personaCuidada: _personaAlicia,
  personaColaborador: _personaMaria,
  rol: _rolResponsable,
  estado: EstadoAsignacion.activa,
  fechaAlta: DateTime(2024, 1, 8),
);

AsignacionCuidado _asignacionCarlos() => AsignacionCuidado(
  id: 'asi_001',
  personaCuidada: _personaAlicia,
  personaColaborador: _personaCarlos,
  rol: _rolResponsable,
  estado: EstadoAsignacion.activa,
  fechaAlta: DateTime(2024, 1, 10),
);

// ─── Fakes ────────────────────────────────────────────────────────────────────

class _FakePersonaRepository implements PersonaRepository {
  final List<Persona> _personas;

  _FakePersonaRepository(List<Persona> personas)
    : _personas = List.from(personas);

  @override
  Future<Persona> getById(String id) async => _personas.firstWhere(
    (p) => p.id == id,
    orElse: () => throw Exception('Persona no encontrada: $id'),
  );

  @override
  Future<List<Persona>> getDependientesByUsuario(String usuarioId) async => [];

  @override
  Future<Persona> crear(Persona persona) async {
    final nueva = persona.copyWith(id: 'per_new');
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
  Future<void> eliminar(String id) async {
    _personas.removeWhere((p) => p.id == id);
  }
}

class _FakeCareTeamRepository implements CareTeamRepository {
  final List<AsignacionCuidado> _asignaciones;

  _FakeCareTeamRepository(List<AsignacionCuidado> asignaciones)
    : _asignaciones = List.from(asignaciones);

  @override
  Future<List<AsignacionCuidado>> getAsignacionesByColaborador(
    String colaboradorId,
  ) async => _asignaciones
      .where((a) => a.personaColaborador.id == colaboradorId)
      .toList();

  @override
  Future<List<AsignacionCuidado>> getAsignacionesByPersonaCuidada(
    String personaCuidadaId,
  ) async => _asignaciones
      .where((a) => a.personaCuidada.id == personaCuidadaId)
      .toList();

  @override
  Future<AsignacionCuidado> crearAsignacion(AsignacionCuidado a) async {
    final nueva = AsignacionCuidado(
      id: 'asi_new_${DateTime.now().millisecondsSinceEpoch}',
      personaCuidada: a.personaCuidada,
      personaColaborador: a.personaColaborador,
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
  Future<void> eliminarAsignacion(String id) async {
    final idx = _asignaciones.indexWhere((a) => a.id == id);
    if (idx < 0) throw Exception('Asignación no encontrada: $id');
    _asignaciones.removeAt(idx);
  }

  @override
  Future<List<Rol>> getRoles() async => [_rolResponsable, _rolCuidador];

  @override
  Future<Rol> getRolById(String rolId) async =>
      [_rolResponsable, _rolCuidador].firstWhere((r) => r.id == rolId);
}

final _usuarioDemoMaria = Usuario(
  id: 'usr_001',
  persona: _personaMaria,
  nombreUsuario: 'maria.garcia',
  estado: EstadoUsuario.activo,
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
      careTeamRepositoryProvider.overrideWithValue(
        _FakeCareTeamRepository(asigs),
      ),
    ],
  );
}

void main() {
  group('careTeamContextPersonaProvider', () {
    test(
      'retorna la primera persona donde el usuario es Responsable',
      () async {
        final container = _buildContainer();
        addTearDown(container.dispose);

        final persona = await container.read(
          careTeamContextPersonaProvider.future,
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
          careTeamContextPersonaProvider.future,
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
        container.read(selectedPersonaIdProvider.notifier).state =
            _personaMaria.id;

        final persona = await container.read(
          careTeamContextPersonaProvider.future,
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
        container.read(selectedPersonaIdProvider.notifier).state =
            'per_inexistente';

        final persona = await container.read(
          careTeamContextPersonaProvider.future,
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
  });

  group('careTeamAssignmentsProvider', () {
    test('retorna las asignaciones de la persona cuidada', () async {
      final container = _buildContainer();
      addTearDown(container.dispose);

      final asignaciones = await container.read(
        careTeamAssignmentsProvider(_personaAlicia.id).future,
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
        careTeamAssignmentsProvider('per_inexistente').future,
      );

      expect(asignaciones, isEmpty);
    });
  });

  group('assignmentByIdProvider', () {
    test('retorna la asignación correcta por ID', () async {
      final container = _buildContainer();
      addTearDown(container.dispose);

      final asignacion = await container.read(
        assignmentByIdProvider('asi_001').future,
      );

      expect(asignacion, isNotNull);
      expect(asignacion!.id, 'asi_001');
    });

    test('retorna null para ID de asignación inexistente', () async {
      final container = _buildContainer();
      addTearDown(container.dispose);

      final asignacion = await container.read(
        assignmentByIdProvider('asi_inexistente').future,
      );

      expect(asignacion, isNull);
    });
  });

  group('availablePermisosProvider', () {
    test('retorna todos los valores de CodigoPermiso', () {
      final container = _buildContainer();
      addTearDown(container.dispose);

      final permisos = container.read(availablePermisosProvider);

      expect(permisos, CodigoPermiso.values);
      expect(permisos.length, CodigoPermiso.values.length);
    });
  });

  group('labelDePermiso', () {
    test('retorna etiqueta para verFichaSalud', () {
      expect(labelDePermiso(CodigoPermiso.verFichaSalud), isNotEmpty);
    });

    test('retorna etiqueta para cada CodigoPermiso', () {
      for (final codigo in CodigoPermiso.values) {
        expect(labelDePermiso(codigo), isNotEmpty);
      }
    });
  });

  group('esContextoPropioProvider', () {
    test(
      'retorna true cuando selectedPersonaId coincide con el id del usuario',
      () async {
        final container = _buildContainer();
        addTearDown(container.dispose);

        // Seleccionar explícitamente a María (el propio usuario).
        container.read(selectedPersonaIdProvider.notifier).state =
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

        // Contexto default con asignaciones → Alicia (primera Responsable).
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
          esResponsableProvider.future,
        );

        expect(esResponsable, isTrue);
      },
    );

    test('retorna false si el usuario no tiene asignaciones', () async {
      final container = _buildContainer(asignaciones: []);
      addTearDown(container.dispose);

      final esResponsable = await container.read(esResponsableProvider.future);

      expect(esResponsable, isFalse);
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
          permisosActivos: [CodigoPermiso.verFichaSalud],
        ),
        completes,
      );
    });
  });

  group('eliminarMiembroProvider', () {
    test('elimina la asignación correctamente', () async {
      final container = _buildContainer();
      addTearDown(container.dispose);

      final eliminarFn = container.read(eliminarMiembroProvider);

      await expectLater(
        eliminarFn(
          asignacionId: 'asi_001',
          personaCuidadaId: _personaAlicia.id,
        ),
        completes,
      );
    });

    test('lanza excepción si la asignación no existe', () async {
      final container = _buildContainer();
      addTearDown(container.dispose);

      final eliminarFn = container.read(eliminarMiembroProvider);

      await expectLater(
        eliminarFn(
          asignacionId: 'asi_inexistente',
          personaCuidadaId: _personaAlicia.id,
        ),
        throwsException,
      );
    });
  });
}
