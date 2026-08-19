import 'package:care_well_app/config/constraints/privacy_content.dart';
import 'package:care_well_app/config/routers/app_routes.dart';
import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/domain/repositories/repositories.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/screens/settings/legal_text_screen.dart';
import 'package:care_well_app/presentation/screens/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _FakeAuthRepository implements AuthRepository {
  final Usuario _usuario;
  _FakeAuthRepository(this._usuario);

  @override
  Future<Usuario> login(String email, String contrasena) async => _usuario;
  @override
  Future<void> register(RegistroData data) async {}
  @override
  Future<void> solicitarRecuperacionContrasena(String email) async {}

  @override
  Future<void> confirmarResetContrasena({
    required String email,
    required String codigo,
    required String contrasenaNueva,
  }) async {}
  @override
  Future<void> reenviarCodigoVerificacion(String email) async {}
  @override
  Future<void> verificarEmail(String email, String codigo) async {}
  @override
  Future<void> logout() async {}
  @override
  Future<void> eliminarCuenta() async {}
  @override
  Future<void> cambiarContrasena({
    required int usuarioId,
    required String contrasenaActual,
    required String contrasenaNueva,
  }) async {}
  @override
  Future<void> crearCredenciales({
    required String email,
    required String contrasena,
    required String imagenDocumento,
  }) async {}
}

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

/// Overrides comunes: usuario logueado y versión de app fija, para que ningún
/// caso toque el plugin real de `package_info_plus`.
List<Override> _overrides({String version = '1.2.0'}) => [
  authRepositoryProvider.overrideWithValue(_FakeAuthRepository(_testUsuario)),
  authStateProvider.overrideWith((ref) {
    final notifier = AuthNotifier(ref.watch(authRepositoryProvider));
    notifier.state = AsyncValue.data(_testUsuario);
    return notifier;
  }),
  appVersionProvider.overrideWith((ref) async => version),
];

Widget _wrapWithUser(Widget child) {
  return ProviderScope(
    overrides: _overrides(),
    child: MaterialApp(home: child),
  );
}

/// Wrapper con un router mínimo de test: registra `settings` y su subruta
/// `privacy` con los mismos nombres que [AppRoutes], sin usar el router real
/// (que arrastra el redirect de sesión y los providers de push).
Widget _wrapWithRouter() {
  final router = GoRouter(
    initialLocation: AppRoutes.settings,
    routes: [
      GoRoute(
        path: AppRoutes.settings,
        name: AppRoutes.settingsName,
        builder: (_, _) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'privacy',
            name: AppRoutes.settingsPrivacyName,
            builder: (_, _) => const LegalTextScreen(
              titulo: 'Política de privacidad',
              contenido: kPrivacyContent,
              version: kPrivacyVersion,
            ),
          ),
        ],
      ),
    ],
  );

  return ProviderScope(
    overrides: _overrides(),
    child: MaterialApp.router(routerConfig: router),
  );
}

/// Usa un viewport de teléfono alto para que toda la lista de Configuración
/// quede montada: el viewport por defecto de los tests (800x600) recorta la
/// sección "Sesión" y los ítems de abajo no llegan a construirse.
void _usarViewportTelefono(WidgetTester tester) {
  tester.view.physicalSize = const Size(400, 1000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

Future<void> _pumpSettings(WidgetTester tester) async {
  _usarViewportTelefono(tester);
  await tester.pumpWidget(_wrapWithUser(const SettingsScreen()));
  await tester.pump();
}

Future<void> _pumpSettingsConRouter(WidgetTester tester) async {
  _usarViewportTelefono(tester);
  await tester.pumpWidget(_wrapWithRouter());
  await tester.pumpAndSettle();
}

void main() {
  group('SettingsScreen', () {
    testWidgets('muestra todas las secciones', (tester) async {
      await _pumpSettings(tester);

      expect(find.text('CUENTA'), findsOneWidget);
      expect(find.text('SEGURIDAD Y PRIVACIDAD'), findsOneWidget);
      expect(find.text('LEGAL'), findsOneWidget);
      expect(find.text('SESIÓN'), findsOneWidget);
    });

    testWidgets('muestra todos los ítems de menú', (tester) async {
      await _pumpSettings(tester);

      expect(find.text('Mi Perfil'), findsOneWidget);
      expect(find.text('Cambiar contraseña'), findsOneWidget);
      expect(find.text('Eliminar cuenta'), findsOneWidget);
      expect(find.text('Términos y condiciones'), findsOneWidget);
      expect(find.text('Política de privacidad'), findsOneWidget);
      expect(find.text('Acerca de CareWell'), findsOneWidget);
      expect(find.text('Cerrar sesión'), findsOneWidget);
    });

    testWidgets('tap en "Acerca de CareWell" abre el diálogo con la versión', (
      tester,
    ) async {
      await _pumpSettings(tester);

      await tester.tap(find.text('Acerca de CareWell'));
      await tester.pumpAndSettle();

      expect(find.byType(AboutDialog), findsOneWidget);
      expect(find.text('Versión 1.2.0'), findsOneWidget);
    });

    testWidgets('tap en "Política de privacidad" navega al documento', (
      tester,
    ) async {
      await _pumpSettingsConRouter(tester);

      await tester.tap(find.text('Política de privacidad'));
      await tester.pumpAndSettle();

      expect(find.byType(LegalTextScreen), findsOneWidget);
      // Discrimina el documento concreto: con find.byType solo, el caso pasaría
      // igual si el ítem navegara por error a Términos y condiciones.
      expect(
        find.widgetWithText(AppBar, 'Política de privacidad'),
        findsOneWidget,
      );
      expect(find.text('Versión $kPrivacyVersion'), findsOneWidget);
    });

    testWidgets('tap en "Cerrar sesión" abre el dialog de confirmación', (
      tester,
    ) async {
      await _pumpSettings(tester);

      await tester.tap(find.text('Cerrar sesión'));
      await tester.pumpAndSettle();

      expect(find.text('¿Cerrar sesión?'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
    });

    testWidgets('dialog logout: tap Cancelar cierra el dialog', (tester) async {
      await _pumpSettings(tester);

      await tester.tap(find.text('Cerrar sesión'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(find.text('¿Cerrar sesión?'), findsNothing);
    });

    testWidgets('tap en "Eliminar cuenta" abre el dialog de confirmación', (
      tester,
    ) async {
      await _pumpSettings(tester);

      await tester.tap(find.text('Eliminar cuenta'));
      await tester.pumpAndSettle();

      expect(find.text('¿Eliminar tu cuenta?'), findsOneWidget);
    });

    testWidgets(
      'dialog eliminar: botón destructivo deshabilitado sin "DELETE"',
      (tester) async {
        await _pumpSettings(tester);

        await tester.tap(find.text('Eliminar cuenta'));
        await tester.pumpAndSettle();

        final btn = tester.widget<TextButton>(
          find.widgetWithText(TextButton, 'Eliminar mi cuenta'),
        );
        expect(btn.onPressed, isNull);
      },
    );

    testWidgets(
      'dialog eliminar: botón destructivo habilitado al escribir "DELETE"',
      (tester) async {
        await _pumpSettings(tester);

        await tester.tap(find.text('Eliminar cuenta'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'DELETE');
        await tester.pump();

        final btn = tester.widget<TextButton>(
          find.widgetWithText(TextButton, 'Eliminar mi cuenta'),
        );
        expect(btn.onPressed, isNotNull);
      },
    );

    testWidgets(
      'dialog eliminar: botón deshabilitado con texto incorrecto "delete"',
      (tester) async {
        await _pumpSettings(tester);

        await tester.tap(find.text('Eliminar cuenta'));
        await tester.pumpAndSettle();

        // "delete" en minúsculas no debe habilitar el botón.
        await tester.enterText(find.byType(TextField), 'delete');
        await tester.pump();

        final btn = tester.widget<TextButton>(
          find.widgetWithText(TextButton, 'Eliminar mi cuenta'),
        );
        expect(btn.onPressed, isNull);
      },
    );
  });
}
