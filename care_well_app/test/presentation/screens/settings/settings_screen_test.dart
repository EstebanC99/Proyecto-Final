import 'package:care_well_app/config/constraints/privacy_content.dart';
import 'package:care_well_app/config/routers/app_routes.dart';
import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/domain/repositories/repositories.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/screens/settings/legal_text_screen.dart';
import 'package:care_well_app/presentation/screens/settings/settings_screen.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
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

/// Overrides comunes: usuario logueado, versión de app fija y avatar sin red,
/// para que ningún caso toque el plugin real de `package_info_plus` ni el
/// backend de imágenes de perfil.
///
/// [auth] permite montar la pantalla con la sesión en loading o en error;
/// [version] a `null` simula que la lectura de la versión falla.
List<Override> _overrides({
  AsyncValue<Usuario?>? auth,
  String? version = '1.2.0',
}) => [
  authRepositoryProvider.overrideWithValue(_FakeAuthRepository(_testUsuario)),
  authStateProvider.overrideWith((ref) {
    final notifier = AuthNotifier(ref.watch(authRepositoryProvider));
    notifier.state = auth ?? AsyncValue.data(_testUsuario);
    return notifier;
  }),
  appVersionProvider.overrideWith((ref) async {
    if (version == null) throw Exception('sin package info');
    return version;
  }),
  personaImagenProvider.overrideWith((ref, id) async => null),
];

Widget _wrapWithUser(
  Widget child, {
  AsyncValue<Usuario?>? auth,
  String? version = '1.2.0',
}) {
  return ProviderScope(
    overrides: _overrides(auth: auth, version: version),
    child: MaterialApp(home: child),
  );
}

/// Wrapper con un router mínimo de test: registra `settings`, su subruta
/// `privacy` y `profile` con los mismos nombres que [AppRoutes], sin usar el
/// router real (que arrastra el redirect de sesión y los providers de push).
///
/// La ruta de perfil monta un stub y no la `ProfileScreen` real: acá sólo se
/// verifica que la navegación ocurra, montar la pantalla verdadera traería sus
/// propios providers a un test de Configuración.
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
      GoRoute(
        path: AppRoutes.profile,
        name: AppRoutes.profileName,
        builder: (_, _) => const Scaffold(body: Text('PERFIL_STUB')),
      ),
    ],
  );

  return ProviderScope(
    overrides: _overrides(),
    child: MaterialApp.router(routerConfig: router),
  );
}

/// Usa un viewport de teléfono alto para que la mayor parte de la lista de
/// Configuración quede montada: el viewport por defecto de los tests (800x600)
/// recorta las secciones de abajo y no llegan a construirse. Es un piso, no se
/// sube más: lo que quede bajo el fold se alcanza con [_asegurarVisible].
void _usarViewportTelefono(WidgetTester tester) {
  tester.view.physicalSize = const Size(400, 1000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

/// Deja visible un elemento que puede quedar bajo el fold.
///
/// Usa `scrollUntilVisible` y no `ensureVisible` porque el `ListView` es
/// perezoso: un ítem todavía no construido no lo encuentra ningún finder. El
/// delta es chico y los intentos acotados para que un finder que nunca aparece
/// falle rápido, en lugar de por timeout.
Future<void> _asegurarVisible(WidgetTester tester, Finder finder) async {
  if (tester.any(finder)) return;
  await tester.scrollUntilVisible(
    finder,
    80,
    scrollable: find.byType(Scrollable).first,
    maxScrolls: 30,
  );
}

/// Monta la pantalla y deja correr el stagger de entrada: con `FadeInUp` un
/// único `pump()` dejaría los bloques a mitad de camino.
Future<void> _pumpSettings(
  WidgetTester tester, {
  AsyncValue<Usuario?>? auth,
  String? version = '1.2.0',
}) async {
  _usarViewportTelefono(tester);
  await tester.pumpWidget(
    _wrapWithUser(const SettingsScreen(), auth: auth, version: version),
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpSettingsConRouter(WidgetTester tester) async {
  _usarViewportTelefono(tester);
  await tester.pumpWidget(_wrapWithRouter());
  await tester.pumpAndSettle();
}

void main() {
  group('SettingsScreen', () {
    testWidgets('muestra el título de la pantalla como encabezado', (
      tester,
    ) async {
      await _pumpSettings(tester);

      expect(find.text('Configuración'), findsOneWidget);
    });

    testWidgets('muestra todas las secciones', (tester) async {
      await _pumpSettings(tester);

      expect(find.text('SEGURIDAD Y PRIVACIDAD'), findsOneWidget);
      expect(find.text('LEGAL'), findsOneWidget);
      await _asegurarVisible(tester, find.text('ZONA SENSIBLE'));
      expect(find.text('ZONA SENSIBLE'), findsOneWidget);
    });

    testWidgets('ya no muestra las secciones Cuenta ni Sesión', (tester) async {
      await _pumpSettings(tester);

      // La cuenta ahora es la tarjeta de usuario y cerrar sesión es un botón
      // suelto: ninguna de las dos secciones existe.
      expect(find.text('CUENTA'), findsNothing);
      expect(find.text('SESIÓN'), findsNothing);
      expect(find.text('Mi Perfil'), findsNothing);
    });

    testWidgets('muestra todos los ítems de menú', (tester) async {
      await _pumpSettings(tester);

      expect(find.text('Cambiar contraseña'), findsOneWidget);
      expect(find.text('Términos y condiciones'), findsOneWidget);
      expect(find.text('Política de privacidad'), findsOneWidget);
      expect(find.text('Acerca de CareWell'), findsOneWidget);
      await _asegurarVisible(tester, find.text('Eliminar cuenta'));
      expect(find.text('Eliminar cuenta'), findsOneWidget);
      await _asegurarVisible(tester, find.text('Cerrar sesión'));
      expect(find.text('Cerrar sesión'), findsOneWidget);
    });

    testWidgets('el ítem de cambiar contraseña explica qué se pedirá', (
      tester,
    ) async {
      await _pumpSettings(tester);

      expect(find.text('Se te pedirá tu contraseña actual'), findsOneWidget);
    });

    testWidgets('cerrar sesión es un botón outline, no un ítem de lista', (
      tester,
    ) async {
      await _pumpSettings(tester);
      await _asegurarVisible(tester, find.text('Cerrar sesión'));

      expect(
        find.widgetWithText(OutlinedButton, 'Cerrar sesión'),
        findsOneWidget,
      );
      expect(find.widgetWithText(SettingsItem, 'Cerrar sesión'), findsNothing);
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
      await _asegurarVisible(tester, find.text('Cerrar sesión'));

      await tester.tap(find.text('Cerrar sesión'));
      await tester.pumpAndSettle();

      expect(find.text('¿Cerrar sesión?'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
    });

    testWidgets('dialog logout: tap Cancelar cierra el dialog', (tester) async {
      await _pumpSettings(tester);
      await _asegurarVisible(tester, find.text('Cerrar sesión'));

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
      await _asegurarVisible(tester, find.text('Eliminar cuenta'));

      await tester.tap(find.text('Eliminar cuenta'));
      await tester.pumpAndSettle();

      expect(find.text('¿Eliminar tu cuenta?'), findsOneWidget);
    });

    testWidgets(
      'dialog eliminar: botón destructivo deshabilitado sin "DELETE"',
      (tester) async {
        await _pumpSettings(tester);
        await _asegurarVisible(tester, find.text('Eliminar cuenta'));

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
        await _asegurarVisible(tester, find.text('Eliminar cuenta'));

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
        await _asegurarVisible(tester, find.text('Eliminar cuenta'));

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

  group('SettingsScreen · tarjeta de usuario', () {
    testWidgets('muestra al usuario logueado', (tester) async {
      await _pumpSettings(tester);

      expect(find.byType(SettingsUserCard), findsOneWidget);
      expect(find.text('María García'), findsOneWidget);
      expect(find.text('maria@example.com'), findsOneWidget);
    });

    testWidgets('mientras la sesión carga muestra el skeleton', (tester) async {
      await _pumpSettings(tester, auth: const AsyncValue.loading());

      expect(find.byType(SettingsUserCardSkeleton), findsOneWidget);
      expect(find.byType(SettingsUserCard), findsNothing);
    });

    testWidgets('tap en la tarjeta navega al perfil', (tester) async {
      await _pumpSettingsConRouter(tester);

      await tester.tap(find.byType(SettingsUserCard));
      await tester.pumpAndSettle();

      expect(find.text('PERFIL_STUB'), findsOneWidget);
    });

    testWidgets('con la sesión en error la pantalla sigue siendo usable', (
      tester,
    ) async {
      await _pumpSettings(
        tester,
        auth: AsyncValue.error(Exception('sesión rota'), StackTrace.empty),
      );

      // La tarjeta se oculta, pero el resto de Configuración —sobre todo el
      // botón de cerrar sesión— tiene que seguir disponible.
      expect(find.byType(SettingsUserCard), findsNothing);
      expect(find.text('SEGURIDAD Y PRIVACIDAD'), findsOneWidget);
      await _asegurarVisible(tester, find.text('Cerrar sesión'));
      expect(
        find.widgetWithText(OutlinedButton, 'Cerrar sesión'),
        findsOneWidget,
      );
    });
  });

  group('SettingsScreen · pie de versión', () {
    testWidgets('muestra la versión instalada', (tester) async {
      await _pumpSettings(tester);
      await _asegurarVisible(tester, find.text('CareWell v1.2.0 · Bubisoft'));

      expect(find.text('CareWell v1.2.0 · Bubisoft'), findsOneWidget);
    });

    testWidgets('degrada sin versión si el provider falla', (tester) async {
      await _pumpSettings(tester, version: null);
      await _asegurarVisible(tester, find.text('CareWell · Bubisoft'));

      expect(find.text('CareWell · Bubisoft'), findsOneWidget);
    });
  });
}
