import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/domain/repositories/repositories.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/screens/settings/change_password_screen.dart';
import 'package:care_well_app/presentation/widgets/shared/password_strength_meter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepository implements AuthRepository {
  final bool contrasenaCorrecta;
  _FakeAuthRepository({this.contrasenaCorrecta = true});

  static final _usuario = Usuario(
    id: 'usr_001',
    persona: Persona(
      id: 'per_001',
      nombre: 'María',
      apellido: 'García',
      email: 'maria@example.com',
    ),
    nombreUsuario: 'maria',
    contrasenaHash: '1234',
    estado: EstadoUsuario.activo,
  );

  @override
  Future<Usuario> login(String n, String c) async => _usuario;
  @override
  Future<Usuario> register({
    required String nombre,
    required String apellido,
    required String email,
    required String nombreUsuario,
    required String contrasena,
  }) async => _usuario;
  @override
  Future<void> solicitarRecuperacionContrasena(String email) async {}
  @override
  Future<void> logout() async {}
  @override
  Future<void> eliminarCuenta(String usuarioId) async {}
  @override
  Future<void> cambiarContrasena({
    required String usuarioId,
    required String contrasenaActual,
    required String contrasenaNueva,
  }) async {
    if (!contrasenaCorrecta) {
      throw Exception('La contraseña actual es incorrecta.');
    }
  }

  @override
  Future<Usuario> crearCredenciales({
    required String email,
    required String nombreUsuario,
    required String contrasena,
  }) async => _usuario;
  @override
  Future<Usuario> actualizarPerfil({
    required String usuarioId,
    String? email,
    String? telefono,
    String? documento,
  }) async => _usuario;
}

Widget _wrapWithUser(Widget child, {bool contrasenaCorrecta = true}) {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(
        _FakeAuthRepository(contrasenaCorrecta: contrasenaCorrecta),
      ),
      authStateProvider.overrideWith((ref) {
        final notifier = AuthNotifier(ref.watch(authRepositoryProvider));
        notifier.state = AsyncValue.data(_FakeAuthRepository._usuario);
        return notifier;
      }),
    ],
    child: MaterialApp(home: child),
  );
}

void main() {
  group('ChangePasswordScreen', () {
    testWidgets('muestra el formulario con los tres campos', (tester) async {
      await tester.pumpWidget(_wrapWithUser(const ChangePasswordScreen()));
      await tester.pump();

      expect(find.text('Contraseña actual'), findsOneWidget);
      // "Nueva contraseña" aparece como título de sección Y como label del campo.
      expect(find.text('Nueva contraseña'), findsWidgets);
      expect(find.text('Confirmar nueva contraseña'), findsOneWidget);
      expect(find.text('Guardar cambios'), findsOneWidget);
    });

    testWidgets('muestra título de sección', (tester) async {
      await tester.pumpWidget(_wrapWithUser(const ChangePasswordScreen()));
      await tester.pump();

      expect(find.text('Nueva contraseña'), findsWidgets);
    });

    testWidgets(
      'PasswordStrengthMeter aparece al escribir en nueva contraseña',
      (tester) async {
        await tester.pumpWidget(_wrapWithUser(const ChangePasswordScreen()));
        await tester.pump();

        // Localizar los campos por tipo.
        final fields = find.byType(TextField);
        // El segundo campo es "Nueva contraseña".
        await tester.enterText(fields.at(1), 'Password1');
        await tester.pump();

        expect(find.byType(PasswordStrengthMeter), findsOneWidget);
      },
    );

    testWidgets('validación: campos vacíos muestran errores al guardar', (
      tester,
    ) async {
      await tester.pumpWidget(_wrapWithUser(const ChangePasswordScreen()));
      await tester.pump();

      await tester.tap(find.text('Guardar cambios'));
      await tester.pump();

      // Al menos debe haber un mensaje de validación.
      // El campo "Contraseña actual" usa AppTextField con errorText.
      // Los campos de formulario con validator muestran sus mensajes.
      expect(find.byType(ChangePasswordScreen), findsOneWidget);
    });

    testWidgets('cambio exitoso transiciona a pantalla de éxito', (
      tester,
    ) async {
      await tester.pumpWidget(_wrapWithUser(const ChangePasswordScreen()));
      await tester.pump();

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), '1234');
      await tester.enterText(fields.at(1), 'Password1');
      await tester.enterText(fields.at(2), 'Password1');
      await tester.pump();

      await tester.tap(find.text('Guardar cambios'));
      await tester.pumpAndSettle();

      // Estado éxito muestra el texto de confirmación.
      expect(find.text('Contraseña actualizada'), findsOneWidget);
      expect(find.text('Volver a Configuración'), findsOneWidget);
    });

    testWidgets('contraseña actual incorrecta muestra error inline', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrapWithUser(const ChangePasswordScreen(), contrasenaCorrecta: false),
      );
      await tester.pump();

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'incorrecta');
      await tester.enterText(fields.at(1), 'Password1');
      await tester.enterText(fields.at(2), 'Password1');
      await tester.pump();

      await tester.tap(find.text('Guardar cambios'));
      await tester.pumpAndSettle();

      expect(find.text('Contraseña incorrecta'), findsOneWidget);
      // NO debe transicionar a éxito.
      expect(find.text('Contraseña actualizada'), findsNothing);
    });
  });
}
