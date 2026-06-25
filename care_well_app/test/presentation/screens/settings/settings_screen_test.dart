import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/domain/repositories/repositories.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/screens/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepository implements AuthRepository {
  final Usuario _usuario;
  _FakeAuthRepository(this._usuario);

  @override
  Future<Usuario> login(String email, String contrasena) async => _usuario;
  @override
  Future<Usuario> register({
    required String nombre,
    required String apellido,
    required String documento,
    required DateTime fechaNacimiento,
    required String email,
    String? telefono,
    required String contrasena,
  }) async => _usuario;
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
  }) async => _usuario;
  @override
  Future<Usuario> actualizarPerfil({
    required int usuarioId,
    String? email,
    String? telefono,
    String? documento,
  }) async => _usuario;
}

final _testUsuario = Usuario(
  id: 101,
  persona: Persona(
    id: 1,
    nombre: 'María',
    apellido: 'García',
    email: 'maria@example.com',
  ),
  contrasena: '1234',
  estado: EstadoUsuario(id: EstadosUsuarioConst.activo, descripcion: 'Activo'),
);

Widget _wrapWithUser(Widget child) {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(
        _FakeAuthRepository(_testUsuario),
      ),
      authStateProvider.overrideWith((ref) {
        final notifier = AuthNotifier(ref.watch(authRepositoryProvider));
        notifier.state = AsyncValue.data(_testUsuario);
        return notifier;
      }),
    ],
    child: MaterialApp(home: child),
  );
}

void main() {
  group('SettingsScreen', () {
    testWidgets('muestra todas las secciones', (tester) async {
      await tester.pumpWidget(_wrapWithUser(const SettingsScreen()));
      await tester.pump();

      expect(find.text('CUENTA'), findsOneWidget);
      expect(find.text('SEGURIDAD Y PRIVACIDAD'), findsOneWidget);
      expect(find.text('LEGAL'), findsOneWidget);
      expect(find.text('SESIÓN'), findsOneWidget);
    });

    testWidgets('muestra todos los ítems de menú', (tester) async {
      await tester.pumpWidget(_wrapWithUser(const SettingsScreen()));
      await tester.pump();

      expect(find.text('Mi Perfil'), findsOneWidget);
      expect(find.text('Cambiar contraseña'), findsOneWidget);
      expect(find.text('Eliminar cuenta'), findsOneWidget);
      expect(find.text('Términos y condiciones'), findsOneWidget);
      expect(find.text('Cerrar sesión'), findsOneWidget);
    });

    testWidgets('tap en "Cerrar sesión" abre el dialog de confirmación', (
      tester,
    ) async {
      await tester.pumpWidget(_wrapWithUser(const SettingsScreen()));
      await tester.pump();

      await tester.tap(find.text('Cerrar sesión'));
      await tester.pumpAndSettle();

      expect(find.text('¿Cerrar sesión?'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
    });

    testWidgets('dialog logout: tap Cancelar cierra el dialog', (tester) async {
      await tester.pumpWidget(_wrapWithUser(const SettingsScreen()));
      await tester.pump();

      await tester.tap(find.text('Cerrar sesión'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(find.text('¿Cerrar sesión?'), findsNothing);
    });

    testWidgets('tap en "Eliminar cuenta" abre el dialog de confirmación', (
      tester,
    ) async {
      await tester.pumpWidget(_wrapWithUser(const SettingsScreen()));
      await tester.pump();

      await tester.tap(find.text('Eliminar cuenta'));
      await tester.pumpAndSettle();

      expect(find.text('¿Eliminar tu cuenta?'), findsOneWidget);
    });

    testWidgets(
      'dialog eliminar: botón destructivo deshabilitado sin "DELETE"',
      (tester) async {
        await tester.pumpWidget(_wrapWithUser(const SettingsScreen()));
        await tester.pump();

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
        await tester.pumpWidget(_wrapWithUser(const SettingsScreen()));
        await tester.pump();

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
        await tester.pumpWidget(_wrapWithUser(const SettingsScreen()));
        await tester.pump();

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
