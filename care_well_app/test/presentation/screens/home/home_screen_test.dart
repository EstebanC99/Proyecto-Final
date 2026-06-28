import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/domain/repositories/repositories.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/screens/home/home_screen.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// ─── Fake repositories ────────────────────────────────────────────────────────

class _FakeAuthRepository implements AuthRepository {
  final Usuario? _usuario;
  _FakeAuthRepository(this._usuario);

  @override
  Future<Usuario> login(String email, String contrasena) async => _usuario!;

  @override
  Future<Usuario> register({
    required String nombre,
    required String apellido,
    required String documento,
    required DateTime fechaNacimiento,
    required String email,
    String? telefono,
    required String contrasena,
  }) async => _usuario!;

  @override
  Future<void> solicitarRecuperacionContrasena(String email) async {}

  @override
  Future<void> logout() async {}

  @override
  Future<void> eliminarCuenta(int usuarioId) async {}

  @override
  Future<void> cambiarContrasena({
    required int usuarioId,
    required String contrasenaActual,
    required String contrasenaNueva,
  }) async {}

  @override
  Future<Usuario> crearCredenciales({
    required String email,
    required String contrasena,
  }) async => _usuario!;

  @override
  Future<Usuario> actualizarPerfil({
    required int usuarioId,
    String? email,
    String? telefono,
    String? documento,
  }) async => _usuario!;
}

// ─── Datos de prueba ─────────────────────────────────────────────────────────

final _testUsuario = Usuario(
  id: 101,
  persona: Persona(
    id: 1,
    nombre: 'María',
    apellido: 'García',
    documento: '28000001',
    fechaNacimiento: DateTime(1990, 1, 1),
    email: 'maria@example.com',
  ),
  contrasena: '1234',
  estado: EstadoUsuario(id: EstadosUsuarioConst.activo, descripcion: 'Activo'),
);

final _testDependiente = Persona(
  id: 2,
  nombre: 'Alicia',
  apellido: 'Rodríguez',
  documento: '5234100',
  fechaNacimiento: DateTime(1943, 7, 22),
);

/// Construye una AsignacionCuidado de prueba a partir de una Persona.
AsignacionCuidado _asignacionDesde(Persona persona) => AsignacionCuidado(
  id: 401,
  personaCuidada: persona,
  colaborador: _testUsuario.persona,
  rol: RolCuidado(
    id: RolesCuidadoConst.responsable,
    descripcion: 'Responsable',
  ),
  estado: EstadoAsignacionCuidado(
    id: EstadosAsignacionConst.activa,
    descripcion: 'Activa',
  ),
  fechaAlta: DateTime(2024, 1, 8),
);

// ─── Helper ──────────────────────────────────────────────────────────────────

/// Construye el widget con los providers sobrescritos directamente
/// para evitar el estado de carga y los timers del skeleton en tests.
Widget _wrap({required List<AsignacionCuidado> asignaciones}) {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(
        _FakeAuthRepository(_testUsuario),
      ),
      // Sobrescribe authStateProvider con un usuario ya autenticado.
      authStateProvider.overrideWith(
        (ref) =>
            AuthNotifier(ref.watch(authRepositoryProvider))
              ..login(_testUsuario.persona.email!, _testUsuario.contrasena),
      ),
      // Sobrescribe assignmentsAsResponsableProvider directamente para evitar el loading
      // state, lo que evita que se monte NavTileSkeleton y sus timers infinitos.
      activeAssignmentsAsResponsableProvider.overrideWith(
        (ref) async => asignaciones,
      ),
      activeAssignmentsAsCuidadorProvider.overrideWith(
        (ref) async => <AsignacionCuidado>[],
      ),
      // Sin estados de ánimo en tests: el badge queda nulo y no rompe el layout.
      ultimoEstadoAnimoProvider.overrideWith((ref) async => null),
    ],
    child: const MaterialApp(home: HomeScreen()),
  );
}

/// Avanza el tiempo suficiente para que todas las animaciones de entrada
/// (animate_do: FadeIn 400ms + delay máx 400ms) concluyan.
Future<void> _settleAnimations(WidgetTester tester) async {
  await tester.pump(); // resuelve FutureProvider
  await tester.pump(
    const Duration(milliseconds: 900),
  ); // animaciones de entrada
}

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('HomeScreen', () {
    testWidgets('monta sin errores (smoke)', (tester) async {
      await tester.pumpWidget(
        _wrap(asignaciones: [_asignacionDesde(_testDependiente)]),
      );
      await _settleAnimations(tester);
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('Caso 1 — lista no vacía muestra NavTile de personas a cargo', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(asignaciones: [_asignacionDesde(_testDependiente)]),
      );
      await _settleAnimations(tester);

      expect(find.text('Personas a cargo'), findsOneWidget);
      expect(find.byType(EmptyStateTile), findsNothing);
    });

    testWidgets('Caso 2 — lista vacía muestra EmptyStateTile', (tester) async {
      await tester.pumpWidget(_wrap(asignaciones: []));
      await _settleAnimations(tester);

      expect(find.byType(EmptyStateTile), findsOneWidget);
      // El NavTile de personas no debe aparecer con lista vacía
      expect(find.text('Personas a cargo'), findsNothing);
    });

    testWidgets('Caso 3 — HomeHeader se renderiza', (tester) async {
      await tester.pumpWidget(_wrap(asignaciones: []));
      await _settleAnimations(tester);

      expect(find.byType(HomeHeader), findsOneWidget);
    });

    testWidgets('Caso 3b — nombre del usuario aparece en el header', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(asignaciones: []));
      await _settleAnimations(tester);

      // El header debe mostrar el nombre del usuario autenticado
      expect(find.textContaining('María'), findsWidgets);
    });

    testWidgets('EmergencyTile siempre visible con lista vacía', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(asignaciones: []));
      await _settleAnimations(tester);
      expect(find.byType(EmergencyTile), findsOneWidget);
    });

    testWidgets('EmergencyTile siempre visible con datos', (tester) async {
      await tester.pumpWidget(
        _wrap(asignaciones: [_asignacionDesde(_testDependiente)]),
      );
      await _settleAnimations(tester);
      expect(find.byType(EmergencyTile), findsOneWidget);
    });

    testWidgets('QuickAccessRow se muestra', (tester) async {
      await tester.pumpWidget(_wrap(asignaciones: []));
      await _settleAnimations(tester);
      expect(find.byType(QuickAccessRow), findsOneWidget);
    });

    testWidgets('tiles fijos del grid siempre se muestran', (tester) async {
      await tester.pumpWidget(
        _wrap(asignaciones: [_asignacionDesde(_testDependiente)]),
      );
      await _settleAnimations(tester);

      expect(find.text('Calendario'), findsOneWidget);
      expect(find.text('Equipo de cuidado'), findsOneWidget);
      expect(find.text('Salud'), findsOneWidget);
    });
  });
}
