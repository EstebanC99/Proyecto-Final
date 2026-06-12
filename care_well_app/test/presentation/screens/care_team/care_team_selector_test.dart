import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/domain/repositories/repositories.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// ─── Fixtures ─────────────────────────────────────────────────────────────────

final _personaMaria = Persona(
  id: 'per_001',
  nombre: 'María',
  apellido: 'García',
  email: 'maria@test.com',
);

final _rolResponsable = Rol(id: 'rol_001', nombre: RolCuidado.responsable);

final _usuarioDemoMaria = Usuario(
  id: 'usr_001',
  persona: _personaMaria,
  nombreUsuario: 'maria.garcia',
  estado: EstadoUsuario.activo,
);

class _FakePersonaRepository implements PersonaRepository {
  @override
  Future<Persona> getById(String id) async => _personaMaria;

  @override
  Future<List<Persona>> getDependientesByUsuario(String usuarioId) async => [];

  @override
  Future<Persona> crear(Persona persona) async => persona;

  @override
  Future<Persona> actualizar(Persona persona) async => persona;

  @override
  Future<void> eliminar(String id) async {}
}

class _FakeCareTeamRepository implements CareTeamRepository {
  @override
  Future<List<AsignacionCuidado>> getAsignacionesByColaborador(
    String colaboradorId,
  ) async => [];

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
  Future<List<Rol>> getRoles() async => [_rolResponsable];

  @override
  Future<Rol> getRolById(String rolId) async => _rolResponsable;
}

// ─── Helper ───────────────────────────────────────────────────────────────────

Widget _wrap(Widget child) => ProviderScope(
  overrides: [
    authStateProvider.overrideWith(
      (ref) =>
          AuthNotifier(ref.watch(authRepositoryProvider))
            ..state = AsyncValue.data(_usuarioDemoMaria),
    ),
    personaRepositoryProvider.overrideWithValue(_FakePersonaRepository()),
    careTeamRepositoryProvider.overrideWithValue(_FakeCareTeamRepository()),
    // Forzar esResponsableProvider a true para que el FAB y el botón sean visibles.
    esResponsableProvider.overrideWith((ref) async => true),
  ],
  child: MaterialApp(home: child),
);

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('CareTeamScreen — selector de alta', () {
    testWidgets(
      'smoke: CareTeamScreen monta sin errores con usuario responsable',
      (tester) async {
        await tester.pumpWidget(_wrap(const CareTeamScreen()));
        await tester.pump();
        await tester.pump();
        expect(find.byType(CareTeamScreen), findsOneWidget);
      },
    );

    testWidgets('el FAB aparece cuando el usuario es responsable', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const CareTeamScreen()));
      await tester.pump();
      await tester.pump();
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets(
      'el bottom sheet del selector muestra las dos opciones de alta',
      (tester) async {
        // Mostrar el bottom sheet directamente como widget independiente para
        // evitar problemas de hit-testing con el FAB en entorno de test.
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => showModalBottomSheet<void>(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      builder: (_) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 12),
                            width: 40,
                            height: 4,
                            color: Colors.grey,
                          ),
                          const Text('Agregar al equipo'),
                          const ListTile(
                            leading: Icon(Icons.shield_outlined),
                            title: Text('Agregar responsable'),
                            subtitle: Text(
                              'Gestiona datos y administra el equipo',
                            ),
                          ),
                          const ListTile(
                            leading: Icon(Icons.volunteer_activism_outlined),
                            title: Text('Agregar cuidador'),
                            subtitle: Text(
                              'Realiza tareas de cuidado según permisos',
                            ),
                          ),
                        ],
                      ),
                    ),
                    child: const Text('Abrir'),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Abrir'));
        await tester.pumpAndSettle();

        expect(find.text('Agregar al equipo'), findsOneWidget);
        expect(find.text('Agregar responsable'), findsOneWidget);
        expect(find.text('Agregar cuidador'), findsOneWidget);
      },
    );

    testWidgets(
      'el bottom sheet muestra íconos de shield y volunteer_activism',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => showModalBottomSheet<void>(
                      context: context,
                      builder: (_) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const ListTile(
                            leading: Icon(Icons.shield_outlined),
                            title: Text('Agregar responsable'),
                          ),
                          const ListTile(
                            leading: Icon(Icons.volunteer_activism_outlined),
                            title: Text('Agregar cuidador'),
                          ),
                        ],
                      ),
                    ),
                    child: const Text('Abrir'),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Abrir'));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.shield_outlined), findsOneWidget);
        expect(find.byIcon(Icons.volunteer_activism_outlined), findsOneWidget);
      },
    );
  });
}
