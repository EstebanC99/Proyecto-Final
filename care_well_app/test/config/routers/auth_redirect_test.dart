import 'package:care_well_app/config/routers/app_router.dart';
import 'package:care_well_app/config/theme/theme.dart';
import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/domain/repositories/repositories.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_fakes/test_fixtures.dart';

/// Usuario de prueba para simular sesión autenticada.
final _usuarioDemo = Usuario(
  id: 101,
  persona: Persona(
    id: 1,
    nombre: 'Test',
    apellido: 'User',
    documento: '1231241',
    fechaNacimiento: DateTime.now(),
  ),
  contrasena: 'hash123',
  estado: estadoUsuarioActivo,
);

/// Fake de [AsignacionCuidadoRepository] que resuelve al instante.
///
/// Evita que [HomeScreen] dispare la llamada real a la API y deje
/// `pumpAndSettle` colgado.
class _FakeAsignacionCuidadoRepository implements AsignacionCuidadoRepository {
  @override
  Future<List<AsignacionCuidado>> obtenerAsignacionesUsuarioLogueado() async =>
      [];

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
  Future<void> eliminarAsignacion(int asignacionId) async {}

  @override
  Future<void> reactivarAsignacion(int asignacionId) async {}
}

void main() {
  group('Router — redirecciones de autenticación', () {
    testWidgets('sin sesión activa → muestra LoginScreen', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final router = container.read(goRouterProvider);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            theme: AppTheme().light,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('con sesión activa → muestra HomeScreen', (tester) async {
      final container = ProviderContainer(
        overrides: [
          authStateProvider.overrideWith(
            (ref) =>
                AuthNotifier(ref.watch(authRepositoryProvider))
                  ..state = AsyncValue.data(_usuarioDemo),
          ),
          asignacionCuidadoRepositoryProvider.overrideWithValue(
            _FakeAsignacionCuidadoRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final router = container.read(goRouterProvider);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            theme: AppTheme().light,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}
