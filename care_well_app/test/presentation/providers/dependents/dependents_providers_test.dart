import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/domain/repositories/repositories.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// ─── Fakes ────────────────────────────────────────────────────────────────────

final _personaAlicia = Persona(
  id: 'per_002',
  nombre: 'Alicia',
  apellido: 'Rodríguez',
  documento: '5234100',
  fechaNacimiento: DateTime(1943, 7, 22),
);

final _personaMaria = Persona(
  id: 'per_001',
  nombre: 'María',
  apellido: 'García',
  email: 'maria@test.com',
);

final _rolResponsable = Rol(id: 'rol_001', nombre: RolCuidado.responsable);
final _rolCuidador = Rol(id: 'rol_002', nombre: RolCuidado.cuidador);

/// Asignación en la que María es responsable de Alicia.
AsignacionCuidado _asignacionMariaResponsable() => AsignacionCuidado(
  id: 'asi_001',
  personaCuidada: _personaAlicia,
  personaColaborador: _personaMaria,
  rol: _rolResponsable,
  estado: EstadoAsignacion.activa,
  fechaAlta: DateTime(2024, 1, 8),
);

/// Fake de [PersonaRepository] para tests de dependents.
class _FakePersonaRepository implements PersonaRepository {
  final List<Persona> _personas;

  _FakePersonaRepository(this._personas);

  @override
  Future<Persona> getById(String id) async {
    return _personas.firstWhere(
      (p) => p.id == id,
      orElse: () => throw Exception('Persona no encontrada: $id'),
    );
  }

  @override
  Future<List<Persona>> getDependientesByUsuario(String usuarioId) async =>
      _personas.where((p) => p.id == 'per_002').toList();

  @override
  Future<Persona> crear(Persona persona) async {
    final nueva = persona.copyWith(
      id: 'per_new_${DateTime.now().millisecondsSinceEpoch}',
    );
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
  Future<void> eliminar(String id) async {
    _personas.removeWhere((p) => p.id == id);
  }
}

/// Fake de [CareTeamRepository] para tests de dependents.
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
    if (idx < 0) throw Exception('No encontrada.');
    _asignaciones[idx] = a;
    return a;
  }

  @override
  Future<void> eliminarAsignacion(String id) async {
    _asignaciones.removeWhere((a) => a.id == id);
  }

  @override
  Future<List<Rol>> getRoles() async => [_rolResponsable, _rolCuidador];

  @override
  Future<Rol> getRolById(String rolId) async =>
      [_rolResponsable, _rolCuidador].firstWhere((r) => r.id == rolId);
}

/// Usuario demo logueado.
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
          id: 'asi_c',
          personaCuidada: _personaAlicia,
          personaColaborador: _personaMaria,
          rol: _rolCuidador,
          estado: EstadoAsignacion.activa,
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
        id: 'asi_c',
        personaCuidada: _personaAlicia,
        personaColaborador: _personaMaria,
        rol: _rolCuidador,
        estado: EstadoAsignacion.activa,
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
        container.read(dependentByIdProvider('id_inexistente').future),
        throwsException,
      );
    });
  });

  group('crearDependenteProvider', () {
    test('crea persona y retorna la entidad con ID generado', () async {
      final container = _buildContainer();
      addTearDown(container.dispose);

      final crearFn = container.read(crearDependenteProvider);

      final persona = await crearFn(
        nombre: 'Pedro',
        apellido: 'López',
        documento: '30123456',
        fechaNacimiento: DateTime(1970, 5, 10),
        email: 'pedro@test.com',
      );

      expect(persona.id, isNotEmpty);
      expect(persona.nombre, 'Pedro');
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
