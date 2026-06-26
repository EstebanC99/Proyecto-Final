import 'package:care_well_app/config/routers/app_router.dart';
import 'package:care_well_app/config/routers/app_routes.dart';
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
    documento: '123123',
    fechaNacimiento: DateTime.now(),
  ),
  contrasena: 'hash123',
  estado: estadoUsuarioActivo,
);

/// Fake de [AsignacionCuidadoRepository] que resuelve al instante.
///
/// Evita que [HomeScreen] (montada por el shell del router) dispare la llamada
/// real a la API y deje `pumpAndSettle` colgado.
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

/// Construye un [ProviderContainer] con sesión autenticada.
ProviderContainer _containerAutenticado() {
  return ProviderContainer(
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
        // ID numérico en la ruta — el router hace int.parse()
        router.go('/care-team/member/401');

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
