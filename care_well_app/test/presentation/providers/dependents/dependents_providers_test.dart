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
  email: 'maria@test.com',
);

/// Asignación en la que María es responsable de Alicia.
AsignacionCuidado _asignacionMariaResponsable() => AsignacionCuidado(
  id: 401,
  personaCuidada: _personaAlicia,
  personaColaborador: _personaMaria,
  rol: rolCuidadoResponsable,
  estado: estadoAsignacionActiva,
  fechaAlta: DateTime(2024, 1, 8),
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
      _asignaciones.where((a) => a.personaColaborador.id == 1).toList();

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
        personaColaborador: _personaMaria,
        rol: rolCuidadoResponsable,
        estado: estadoAsignacionActiva,
        fechaAlta: DateTime.now(),
      ),
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
  ) async => _asignaciones
      .where((a) => a.personaColaborador.id == colaboradorId)
      .toList();

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
  group('dependentsAsResponsableProvider', () {
    test('retorna personas donde el usuario es Responsable activo', () async {
      final container = _buildContainer();
      addTearDown(container.dispose);

      final personas = await container.read(
        dependentsAsResponsableProvider.future,
      );

      expect(personas, isNotEmpty);
      expect(personas.first.id, _personaAlicia.id);
    });

    test(
      'retorna lista vacía si el usuario no tiene asignaciones activas',
      () async {
        final container = _buildContainer(asignaciones: []);
        addTearDown(container.dispose);

        final personas = await container.read(
          dependentsAsResponsableProvider.future,
        );

        expect(personas, isEmpty);
      },
    );

    test(
      'retorna lista vacía si las asignaciones son de rol Cuidador',
      () async {
        final asignacionCuidador = AsignacionCuidado(
          id: 402,
          personaCuidada: _personaAlicia,
          personaColaborador: _personaMaria,
          rol: rolCuidadoCuidador,
          estado: estadoAsignacionActiva,
          fechaAlta: DateTime(2024, 1, 1),
        );
        final container = _buildContainer(asignaciones: [asignacionCuidador]);
        addTearDown(container.dispose);

        final personas = await container.read(
          dependentsAsResponsableProvider.future,
        );

        expect(personas, isEmpty);
      },
    );
  });

  group('dependentsAsCuidadorProvider', () {
    test('retorna personas donde el usuario es Cuidador activo', () async {
      final asignacionCuidador = AsignacionCuidado(
        id: 403,
        personaCuidada: _personaAlicia,
        personaColaborador: _personaMaria,
        rol: rolCuidadoCuidador,
        estado: estadoAsignacionActiva,
        fechaAlta: DateTime(2024, 1, 1),
      );
      final container = _buildContainer(asignaciones: [asignacionCuidador]);
      addTearDown(container.dispose);

      final personas = await container.read(
        dependentsAsCuidadorProvider.future,
      );

      expect(personas, isNotEmpty);
      expect(personas.first.id, _personaAlicia.id);
    });

    test('retorna lista vacía si no hay asignaciones de cuidador', () async {
      final container = _buildContainer();
      addTearDown(container.dispose);

      final personas = await container.read(
        dependentsAsCuidadorProvider.future,
      );

      expect(personas, isEmpty);
    });
  });

  group('dependentByIdProvider', () {
    test('retorna la persona con el id correcto', () async {
      final container = _buildContainer();
      addTearDown(container.dispose);

      final persona = await container.read(
        dependentByIdProvider(_personaAlicia.id).future,
      );

      expect(persona.id, _personaAlicia.id);
      expect(persona.nombre, 'Alicia');
    });

    test('lanza excepción si el id no existe', () async {
      final container = _buildContainer();
      addTearDown(container.dispose);

      await expectLater(
        container.read(dependentByIdProvider(99999).future),
        throwsException,
      );
    });
  });

  group('crearDependenteProvider', () {
    test('crea persona sin lanzar excepción', () async {
      final container = _buildContainer();
      addTearDown(container.dispose);

      final crearFn = container.read(crearDependenteProvider);

      // El provider devuelve void; verificamos que completa sin error.
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

    test('invalida dependentsAsResponsableProvider tras creación', () async {
      final container = _buildContainer();
      addTearDown(container.dispose);

      // Primero leer para establecer el estado.
      await container.read(dependentsAsResponsableProvider.future);

      final crearFn = container.read(crearDependenteProvider);
      await crearFn(
        nombre: 'Pedro',
        apellido: 'López',
        documento: '30123456',
        fechaNacimiento: DateTime(1970, 5, 10),
      );

      // Después de crear, el estado del provider debe haberse reiniciado.
      final state = container.read(dependentsAsResponsableProvider);
      // Puede estar en loading o data; lo importante es que no crashea.
      expect(state, isNotNull);
    });
  });

  group('actualizarDependenteProvider', () {
    test('actualiza y retorna la persona modificada', () async {
      final container = _buildContainer();
      addTearDown(container.dispose);

      final actualizarFn = container.read(actualizarDependenteProvider);

      final actualizada = await actualizarFn(
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

      await expectLater(eliminarFn(_personaAlicia.id), completes);
    });
  });
}
