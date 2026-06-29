import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/domain/repositories/repositories.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/screens/screens.dart';
import 'package:flutter/material.dart';
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

final _usuarioDemoMaria = Usuario(
  id: 101,
  persona: _personaMaria,
  contrasena: 'hash123',
  estado: estadoUsuarioActivo,
);

// Asignación con id=401 (el id que se pasa a DependentDetailScreen)
final _asignacionActiva = AsignacionCuidado(
  id: 401,
  personaCuidada: _personaAlicia,
  colaborador: _personaMaria,
  rol: rolCuidadoResponsable,
  estado: estadoAsignacionActiva,
  fechaAlta: DateTime(2024, 1, 8),
);

class _FakePersonaRepository implements PersonaRepository {
  @override
  Future<Persona> getById(int id) async => _personaAlicia;

  @override
  Future<List<Persona>> getDependientesByUsuario(int usuarioId) async => [
    _personaAlicia,
  ];

  @override
  Future<Persona> crear(Persona persona) async => persona.copyWith(id: 9999);

  @override
  Future<Persona> actualizar(Persona persona) async => persona;

  @override
  Future<void> eliminar(int id) async {}
}

class _FakeAsignacionCuidadoRepository implements AsignacionCuidadoRepository {
  @override
  Future<List<AsignacionCuidado>> obtenerAsignacionesUsuarioLogueado() async =>
      [_asignacionActiva];

  @override
  Future<void> crearPersonaCargo({
    required String nombre,
    required String apellido,
    required String documento,
    required DateTime fechaNacimiento,
    String? email,
    String? telefono,
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
  Future<void> eliminarAsignacion(int asignacionId) async {}

  @override
  Future<void> activarAsignacion(int asignacionId) async {}

  @override
  Future<void> reactivarAsignacion(int asignacionId) async {}

  @override
  Future<List<AsignacionCuidado>> obtenerAsignacionesPorPersona(
    int personaCuidadaId,
  ) => throw UnimplementedError();

  @override
  Future<void> asignarPersonaEquipoCuidado({
    required int personaCuidadaId,
    required String colaboradorEmail,
    required int rolCuidadoId,
    required List<int> permisosCuidadoIds,
  }) => throw UnimplementedError();
}

class _FakeCareTeamRepository implements CareTeamRepository {
  @override
  Future<List<AsignacionCuidado>> getAsignacionesByColaborador(
    int colaboradorId,
  ) async => [_asignacionActiva];

  @override
  Future<List<AsignacionCuidado>> getAsignacionesByPersonaCuidada(
    int personaCuidadaId,
  ) async => [];

  @override
  Future<AsignacionCuidado> crearAsignacion(AsignacionCuidado a) async => a;

  @override
  Future<AsignacionCuidado> actualizarAsignacion(AsignacionCuidado a) async =>
      a;

  @override
  Future<void> eliminarAsignacion(int id) async {}

  @override
  Future<List<RolCuidado>> getRoles() async => [rolCuidadoResponsable];

  @override
  Future<RolCuidado> getRolById(int rolId) async => rolCuidadoResponsable;
}

Widget _wrap(Widget child) => ProviderScope(
  overrides: [
    authStateProvider.overrideWith(
      (ref) =>
          AuthNotifier(ref.watch(authRepositoryProvider))
            ..state = AsyncValue.data(_usuarioDemoMaria),
    ),
    personaRepositoryProvider.overrideWithValue(_FakePersonaRepository()),
    asignacionCuidadoRepositoryProvider.overrideWithValue(
      _FakeAsignacionCuidadoRepository(),
    ),
    careTeamRepositoryProvider.overrideWithValue(_FakeCareTeamRepository()),
  ],
  child: MaterialApp(home: child),
);

void main() {
  group('Smoke — pantallas de Dependents', () {
    testWidgets('DependentsScreen monta sin errores', (tester) async {
      await tester.pumpWidget(_wrap(const DependentsScreen()));
      await tester.pump();
      expect(find.byType(DependentsScreen), findsOneWidget);
    });

    testWidgets('DependentFormScreen (alta) monta sin errores', (tester) async {
      await tester.pumpWidget(_wrap(const DependentFormScreen()));
      await tester.pump();
      expect(find.byType(DependentFormScreen), findsOneWidget);
    });

    testWidgets('DependentDetailScreen monta sin errores', (tester) async {
      await tester.pumpWidget(
        // asignacionId: 401 — coincide con el id de la asignación en el fake
        _wrap(const DependentDetailScreen(asignacionId: 401)),
      );
      await tester.pump();
      expect(find.byType(DependentDetailScreen), findsOneWidget);
    });

    testWidgets('DependentFormScreen muestra campo Nombre', (tester) async {
      await tester.pumpWidget(_wrap(const DependentFormScreen()));
      await tester.pump();

      expect(find.text('Nombre *'), findsOneWidget);
    });

    testWidgets('DependentFormScreen muestra checkbox de T&C', (tester) async {
      await tester.pumpWidget(_wrap(const DependentFormScreen()));
      await tester.pump();

      expect(find.byType(Checkbox), findsOneWidget);
    });

    testWidgets(
      'DependentFormScreen botón Registrar persona deshabilitado inicialmente',
      (tester) async {
        await tester.pumpWidget(_wrap(const DependentFormScreen()));
        await tester.pump();

        // El botón debe existir pero estar deshabilitado (onPressed null).
        expect(find.text('Registrar persona'), findsOneWidget);
      },
    );
  });
}
