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

final _rolResponsable = Rol(
  id: 'rol_001',
  nombre: RolCuidado.responsable,
  permisos: [
    const Permiso(
      id: 'prm_001',
      codigo: CodigoPermiso.verFichaSalud,
      descripcion: 'Ver ficha de salud',
    ),
  ],
);

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

final _usuarioDemoMaria = Usuario(
  id: 'usr_001',
  persona: _personaMaria,
  nombreUsuario: 'maria.garcia',
  estado: EstadoUsuario.activo,
);

// ─── Fake repositories ────────────────────────────────────────────────────────

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
  @override
  Future<List<AsignacionCuidado>> getAsignacionesByColaborador(
    String colaboradorId,
  ) async => colaboradorId == 'per_001' ? [_asignacionMaria()] : [];

  @override
  Future<List<AsignacionCuidado>> getAsignacionesByPersonaCuidada(
    String personaCuidadaId,
  ) async => [_asignacionMaria(), _asignacionCarlos()];

  @override
  Future<AsignacionCuidado> crearAsignacion(AsignacionCuidado a) async => a;

  @override
  Future<AsignacionCuidado> actualizarAsignacion(AsignacionCuidado a) async =>
      a;

  @override
  Future<void> eliminarAsignacion(String id) async {}

  @override
  Future<List<Rol>> getRoles() async => [_rolResponsable];

  @override
  Future<Rol> getRolById(String rolId) async => _rolResponsable;
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
      await tester.pumpWidget(
        _wrap(const CareTeamMemberScreen(memberId: 'asi_003')),
      );
      await tester.pump();
      await tester.pump();
      expect(find.byType(CareTeamMemberScreen), findsOneWidget);
    });

    testWidgets('CareTeamMemberScreen con memberId inexistente no crashea', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const CareTeamMemberScreen(memberId: 'asi_inexistente')),
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

    testWidgets(
      'CareTeamFormScreen muestra todos los toggles de CodigoPermiso',
      (tester) async {
        await tester.pumpWidget(
          _wrap(const CareTeamFormScreen(formType: CareTeamFormType.caregiver)),
        );
        await tester.pump();
        // Debe haber un Switch por cada CodigoPermiso.
        expect(find.byType(Switch), findsNWidgets(CodigoPermiso.values.length));
      },
    );
  });
}
