import 'package:care_well_app/config/routers/app_router.dart';
import 'package:care_well_app/config/theme/theme.dart';
import 'package:care_well_app/domain/entities/entities.dart';
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
    email: 'test@example.com',
  ),
  contrasena: 'hash123',
  estado: estadoUsuarioActivo,
);

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
