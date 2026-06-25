import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/domain/repositories/repositories.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../_fakes/test_fixtures.dart';

// ─── Fixtures ─────────────────────────────────────────────────────────────────

final _personaAlicia = Persona(id: 2, nombre: 'Alicia', apellido: 'Rodríguez');

final _personaMaria = Persona(
  id: 1,
  nombre: 'María',
  apellido: 'García',
  email: 'maria@test.com',
);

final _personaCarlos = Persona(
  id: 3,
  nombre: 'Carlos',
  apellido: 'Pérez',
  email: 'carlos@test.com',
);

AsignacionCuidado _asignacionMaria() => AsignacionCuidado(
  id: 403,
  personaCuidada: _personaAlicia,
  personaColaborador: _personaMaria,
  rol: rolCuidadoResponsable,
  estado: estadoAsignacionActiva,
  fechaAlta: DateTime(2024, 1, 8),
);

AsignacionCuidado _asignacionCarlos() => AsignacionCuidado(
  id: 401,
  personaCuidada: _personaAlicia,
  personaColaborador: _personaCarlos,
  rol: rolCuidadoResponsable,
  estado: estadoAsignacionActiva,
  fechaAlta: DateTime(2024, 1, 10),
);

final _usuarioDemoMaria = Usuario(
  id: 101,
  persona: _personaMaria,
  contrasena: 'hash123',
  estado: estadoUsuarioActivo,
);

// ─── Fake repositories ────────────────────────────────────────────────────────

class _FakePersonaRepository implements PersonaRepository {
  @override
  Future<Persona> getById(int id) async => _personaAlicia;

  @override
  Future<List<Persona>> getDependientesByUsuario(int usuarioId) async => [
    _personaAlicia,
  ];

  @override
  Future<Persona> crear(Persona persona) async => persona.copyWith(id: 10000);

  @override
  Future<Persona> actualizar(Persona persona) async => persona;

  @override
  Future<void> eliminar(int id) async {}
}

class _FakeAsignacionCuidadoRepository implements AsignacionCuidadoRepository {
  @override
  Future<List<AsignacionCuidado>> obtenerAsignacionesUsuarioLogueado() async =>
      [_asignacionMaria()];

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
}

class _FakeCareTeamRepository implements CareTeamRepository {
  @override
  Future<List<AsignacionCuidado>> getAsignacionesByColaborador(
    int colaboradorId,
  ) async => colaboradorId == 1 ? [_asignacionMaria()] : [];

  @override
  Future<List<AsignacionCuidado>> getAsignacionesByPersonaCuidada(
    int personaCuidadaId,
  ) async => [_asignacionMaria(), _asignacionCarlos()];

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
  group('Smoke — pantallas de CareTeam', () {
    testWidgets('CareTeamScreen monta sin errores', (tester) async {
      await tester.pumpWidget(_wrap(const CareTeamScreen()));
      await tester.pump();
      expect(find.byType(CareTeamScreen), findsOneWidget);
    });

    testWidgets('CareTeamFormScreen (responsable) monta sin errores', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const CareTeamFormScreen(formType: CareTeamFormType.responsible)),
      );
      await tester.pump();
      expect(find.byType(CareTeamFormScreen), findsOneWidget);
    });

    testWidgets('CareTeamFormScreen (cuidador) monta sin errores', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const CareTeamFormScreen(formType: CareTeamFormType.caregiver)),
      );
      await tester.pump();
      expect(find.byType(CareTeamFormScreen), findsOneWidget);
    });

    testWidgets('CareTeamMemberScreen con memberId existente monta sin crash', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const CareTeamMemberScreen(memberId: 403)));
      await tester.pump();
      await tester.pump();
      expect(find.byType(CareTeamMemberScreen), findsOneWidget);
    });

    testWidgets('CareTeamMemberScreen con memberId inexistente no crashea', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const CareTeamMemberScreen(memberId: 99999)),
      );
      await tester.pump();
      await tester.pump();
      // Debe mostrar un error inline en lugar de crashear.
      expect(find.byType(CareTeamMemberScreen), findsOneWidget);
    });

    testWidgets('CareTeamScreen muestra título "Equipo de cuidado"', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const CareTeamScreen()));
      await tester.pump();
      expect(find.text('Equipo de cuidado'), findsOneWidget);
    });

    testWidgets('CareTeamFormScreen responsable muestra sección de permisos', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const CareTeamFormScreen(formType: CareTeamFormType.responsible)),
      );
      await tester.pump();
      expect(find.text('Permisos asignados'), findsOneWidget);
    });

    testWidgets('CareTeamFormScreen muestra todos los toggles de CodigoPermiso', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const CareTeamFormScreen(formType: CareTeamFormType.caregiver)),
      );
      await tester.pump();
      // Debe haber un Switch por cada permiso disponible (7 permisos en PermisosCuidadoConst).
      expect(find.byType(Switch), findsNWidgets(7));
    });
  });
}
