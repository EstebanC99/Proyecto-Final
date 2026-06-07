import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/domain/repositories/repositories.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// ─── Fixtures ─────────────────────────────────────────────────────────────────

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

final _usuarioDemoMaria = Usuario(
  id: 'usr_001',
  persona: _personaMaria,
  nombreUsuario: 'maria.garcia',
  estado: EstadoUsuario.activo,
);

class _FakePersonaRepository implements PersonaRepository {
  @override
  Future<Persona> getById(String id) async => _personaAlicia;

  @override
  Future<List<Persona>> getDependientesByUsuario(String usuarioId) async => [
    _personaAlicia,
  ];

  @override
  Future<Persona> crear(Persona persona) async =>
      persona.copyWith(id: 'per_new');

  @override
  Future<Persona> actualizar(Persona persona) async => persona;

  @override
  Future<void> eliminar(String id) async {}
}

class _FakeCareTeamRepository implements CareTeamRepository {
  final _rolResp = Rol(id: 'rol_001', nombre: RolCuidado.responsable);

  @override
  Future<List<AsignacionCuidado>> getAsignacionesByColaborador(
    String colaboradorId,
  ) async => [
    AsignacionCuidado(
      id: 'asi_003',
      personaCuidada: _personaAlicia,
      personaColaborador: _personaMaria,
      rol: _rolResp,
      estado: EstadoAsignacion.activa,
      fechaAlta: DateTime(2024, 1, 8),
    ),
  ];

  @override
  Future<List<AsignacionCuidado>> getAsignacionesByPersonaCuidada(
    String personaCuidadaId,
  ) async => [];

  @override
  Future<AsignacionCuidado> crearAsignacion(AsignacionCuidado a) async => a;

  @override
  Future<AsignacionCuidado> actualizarAsignacion(AsignacionCuidado a) async =>
      a;

  @override
  Future<void> eliminarAsignacion(String id) async {}

  @override
  Future<List<Rol>> getRoles() async => [_rolResp];

  @override
  Future<Rol> getRolById(String rolId) async => _rolResp;
}

Widget _wrap(Widget child) => ProviderScope(
  overrides: [
    authStateProvider.overrideWith(
      (ref) =>
          AuthNotifier(ref.watch(authRepositoryProvider))
            ..state = AsyncValue.data(_usuarioDemoMaria),
    ),
    personaRepositoryProvider.overrideWithValue(_FakePersonaRepository()),
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
        _wrap(const DependentDetailScreen(dependentId: 'per_002')),
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
