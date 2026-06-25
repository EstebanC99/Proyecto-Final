import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/domain/repositories/repositories.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/screens/auth/account_created_screen.dart';
import 'package:care_well_app/presentation/screens/auth/create_credentials_screen.dart';
import 'package:care_well_app/presentation/screens/auth/login_screen.dart';
import 'package:care_well_app/presentation/screens/auth/recover_password_screen.dart';
import 'package:care_well_app/presentation/screens/auth/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fake de repositorio que implementa todos los métodos requeridos.
class _FakeAuthRepository implements AuthRepository {
  static final _usuario = Usuario(
    id: 101,
    persona: Persona(
      id: 1,
      nombre: 'Test',
      apellido: 'User',
      email: 'test@example.com',
    ),
    contrasena: '1234',
    estado: EstadoUsuario(
      id: EstadosUsuarioConst.activo,
      descripcion: 'Activo',
    ),
  );

  @override
  Future<Usuario> login(String email, String contrasena) async => _usuario;

  @override
  Future<void> register({
    required String nombre,
    required String apellido,
    required String documento,
    required DateTime fechaNacimiento,
    required String email,
    String? telefono,
    required String contrasena,
  }) async {}

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

Widget _wrap(Widget child) => ProviderScope(
  overrides: [authRepositoryProvider.overrideWithValue(_FakeAuthRepository())],
  child: MaterialApp(home: child),
);

void main() {
  group('Smoke — pantallas de autenticación', () {
    testWidgets('LoginScreen monta sin errores', (tester) async {
      await tester.pumpWidget(_wrap(const LoginScreen()));
      await tester.pump();
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('LoginScreen muestra campo Email', (tester) async {
      await tester.pumpWidget(_wrap(const LoginScreen()));
      await tester.pump();
      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('LoginScreen muestra campo Contraseña', (tester) async {
      await tester.pumpWidget(_wrap(const LoginScreen()));
      await tester.pump();
      expect(find.text('Contraseña'), findsOneWidget);
    });

    testWidgets('LoginScreen muestra botón Ingresar', (tester) async {
      await tester.pumpWidget(_wrap(const LoginScreen()));
      await tester.pump();
      expect(find.text('Ingresar'), findsOneWidget);
    });

    testWidgets('LoginScreen muestra link Crear cuenta', (tester) async {
      await tester.pumpWidget(_wrap(const LoginScreen()));
      await tester.pump();
      expect(find.text('Crear cuenta'), findsOneWidget);
    });

    testWidgets('RegisterScreen monta sin errores', (tester) async {
      await tester.pumpWidget(_wrap(const RegisterScreen()));
      await tester.pump();
      expect(find.byType(RegisterScreen), findsOneWidget);
    });

    testWidgets(
      'RegisterScreen muestra paso 1 con campos de datos personales',
      (tester) async {
        await tester.pumpWidget(_wrap(const RegisterScreen()));
        await tester.pump();
        expect(find.text('Nombre'), findsOneWidget);
        expect(find.text('Apellido'), findsOneWidget);
        expect(find.text('DNI'), findsOneWidget);
        expect(find.text('Fecha de nacimiento'), findsOneWidget);
        expect(find.text('Email'), findsOneWidget);
      },
    );

    testWidgets('RegisterScreen muestra "Paso 1 de 2"', (tester) async {
      await tester.pumpWidget(_wrap(const RegisterScreen()));
      await tester.pump();
      expect(find.text('Paso 1 de 2'), findsOneWidget);
    });

    testWidgets('RecoverPasswordScreen monta sin errores', (tester) async {
      await tester.pumpWidget(_wrap(const RecoverPasswordScreen()));
      await tester.pump();
      expect(find.byType(RecoverPasswordScreen), findsOneWidget);
    });

    testWidgets('RecoverPasswordScreen muestra campo Email', (tester) async {
      await tester.pumpWidget(_wrap(const RecoverPasswordScreen()));
      await tester.pump();
      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('RecoverPasswordScreen muestra botón enviar', (tester) async {
      await tester.pumpWidget(_wrap(const RecoverPasswordScreen()));
      await tester.pump();
      expect(find.text('Enviar link de restablecimiento'), findsOneWidget);
    });

    testWidgets('CreateCredentialsScreen monta sin errores', (tester) async {
      await tester.pumpWidget(_wrap(const CreateCredentialsScreen()));
      await tester.pump();
      expect(find.byType(CreateCredentialsScreen), findsOneWidget);
    });

    testWidgets('CreateCredentialsScreen muestra campos requeridos', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const CreateCredentialsScreen()));
      await tester.pump();
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Nueva contraseña'), findsOneWidget);
      expect(find.text('Confirmar contraseña'), findsOneWidget);
    });

    testWidgets('CreateCredentialsScreen NO muestra campo Nombre de usuario', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const CreateCredentialsScreen()));
      await tester.pump();
      expect(find.text('Nombre de usuario'), findsNothing);
    });

    testWidgets('CreateCredentialsScreen muestra botón crear credenciales', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const CreateCredentialsScreen()));
      await tester.pump();
      expect(find.text('Crear credenciales'), findsOneWidget);
    });

    testWidgets('AccountCreatedScreen monta sin errores', (tester) async {
      await tester.pumpWidget(_wrap(const AccountCreatedScreen()));
      await tester.pump();
      // ZoomIn de animate_do tiene timer de animacion; drenamos para evitar timers pendientes.
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(AccountCreatedScreen), findsOneWidget);
    });

    testWidgets('AccountCreatedScreen muestra texto "Cuenta creada"', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const AccountCreatedScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Cuenta creada'), findsOneWidget);
    });

    testWidgets('AccountCreatedScreen muestra botón "Ir al login"', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const AccountCreatedScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Ir al login'), findsOneWidget);
    });
  });
}
