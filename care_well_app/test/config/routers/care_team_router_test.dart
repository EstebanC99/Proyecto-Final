import 'package:care_well_app/config/routers/app_router.dart';
import 'package:care_well_app/config/routers/app_routes.dart';
import 'package:care_well_app/config/theme/theme.dart';
import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Usuario de prueba para simular sesión autenticada.
final _usuarioDemo = Usuario(
  id: 'usr_test',
  persona: Persona(
    id: 'per_test',
    nombre: 'Test',
    apellido: 'User',
    email: 'test@example.com',
  ),
  nombreUsuario: 'demo',
  estado: EstadoUsuario.activo,
);

/// Construye un [ProviderContainer] con sesión autenticada.
ProviderContainer _containerAutenticado() {
  return ProviderContainer(
    overrides: [
      authStateProvider.overrideWith(
        (ref) =>
            AuthNotifier(ref.watch(authRepositoryProvider))
              ..state = AsyncValue.data(_usuarioDemo),
      ),
    ],
  );
}

void main() {
  group('Router — rutas de care_team', () {
    testWidgets(
      'navegar a add-responsible muestra CareTeamFormScreen y NO CareTeamMemberScreen',
      (tester) async {
        final container = _containerAutenticado();
        addTearDown(container.dispose);

        final router = container.read(goRouterProvider);
        // Navega directamente a la ruta de agregar responsable.
        router.go(AppRoutes.careTeamAddResponsible);

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

        expect(find.byType(CareTeamFormScreen), findsOneWidget);
        expect(find.byType(CareTeamMemberScreen), findsNothing);
      },
    );

    testWidgets(
      'navegar a add-caregiver muestra CareTeamFormScreen y NO CareTeamMemberScreen',
      (tester) async {
        final container = _containerAutenticado();
        addTearDown(container.dispose);

        final router = container.read(goRouterProvider);
        router.go(AppRoutes.careTeamAddCaregiver);

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

        expect(find.byType(CareTeamFormScreen), findsOneWidget);
        expect(find.byType(CareTeamMemberScreen), findsNothing);
      },
    );

    testWidgets(
      'navegar a member/:memberId muestra CareTeamMemberScreen y NO CareTeamFormScreen',
      (tester) async {
        final container = _containerAutenticado();
        addTearDown(container.dispose);

        final router = container.read(goRouterProvider);
        router.go('/care-team/member/asi_001');

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

        expect(find.byType(CareTeamMemberScreen), findsOneWidget);
        expect(find.byType(CareTeamFormScreen), findsNothing);
      },
    );
  });
}
