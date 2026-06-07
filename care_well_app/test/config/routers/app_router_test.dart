import 'package:care_well_app/config/routers/app_router.dart';
import 'package:care_well_app/config/routers/app_routes.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('goRouterProvider', () {
    test('crea el router correctamente', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final router = container.read(goRouterProvider);
      expect(router, isNotNull);
    });

    test('authStateProvider arranca sin usuario autenticado', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(authStateProvider);
      expect(state.valueOrNull, isNull);
    });

    test('AppRoutes define los paths correctos', () {
      expect(AppRoutes.login, '/auth/login');
      expect(AppRoutes.home, '/home');
      expect(AppRoutes.dependents, '/dependents');
      expect(AppRoutes.emergency, '/emergency');
    });
  });
}
