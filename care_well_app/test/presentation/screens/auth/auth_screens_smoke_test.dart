import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/domain/repositories/repositories.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/screens/auth/account_created_screen.dart';
import 'package:care_well_app/presentation/screens/auth/create_credentials_screen.dart';
import 'package:care_well_app/presentation/screens/auth/login_screen.dart';
import 'package:care_well_app/presentation/screens/auth/recover_password_screen.dart';
import 'package:care_well_app/presentation/screens/auth/register_screen.dart';
import 'package:care_well_app/presentation/screens/auth/reset_password_screen.dart';
import 'package:care_well_app/presentation/screens/auth/reset_password_success_screen.dart';
import 'package:care_well_app/presentation/screens/auth/verify_email_screen.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
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
      documento: '28000001',
      fechaNacimiento: DateTime(1990, 1, 1),
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

    testWidgets('RegisterScreen muestra "Paso 1 de 3"', (tester) async {
      await tester.pumpWidget(_wrap(const RegisterScreen()));
      await tester.pump();
      expect(find.text('Paso 1 de 3'), findsOneWidget);
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
      expect(find.text('Enviar código'), findsOneWidget);
    });

    // ResetPasswordScreen arranca un cooldown (Timer.periodic) en initState.
    // Los tests deben drenarlo antes de terminar para no dejar timers
    // pendientes (flutter_test falla si queda un Timer activo al finalizar).
    testWidgets('ResetPasswordScreen monta sin errores', (tester) async {
      await tester.pumpWidget(
        _wrap(const ResetPasswordScreen(email: 'test@example.com')),
      );
      await tester.pump();
      expect(find.byType(ResetPasswordScreen), findsOneWidget);
      await tester.pump(const Duration(seconds: 61));
    });

    testWidgets(
      'ResetPasswordScreen muestra el email y los campos requeridos',
      (tester) async {
        await tester.pumpWidget(
          _wrap(const ResetPasswordScreen(email: 'test@example.com')),
        );
        await tester.pump();
        expect(find.textContaining('test@example.com'), findsOneWidget);
        expect(find.text('Código de verificación'), findsOneWidget);
        expect(find.text('Nueva contraseña'), findsWidgets);
        expect(find.text('Confirmar nueva contraseña'), findsOneWidget);
        expect(find.text('Restablecer contraseña'), findsOneWidget);
        await tester.pump(const Duration(seconds: 61));
      },
    );

    testWidgets(
      'ResetPasswordScreen muestra el cooldown de reenvío al entrar',
      (tester) async {
        await tester.pumpWidget(
          _wrap(const ResetPasswordScreen(email: 'test@example.com')),
        );
        await tester.pump();
        // Al llegar recién se pidió un código: el link de reenvío arranca
        // en cooldown (60s) en vez de habilitado.
        expect(
          find.textContaining('Podés reenviar el código en'),
          findsOneWidget,
        );
        await tester.pump(const Duration(seconds: 61));
      },
    );

    testWidgets('ResetPasswordSuccessScreen monta sin errores', (tester) async {
      await tester.pumpWidget(_wrap(const ResetPasswordSuccessScreen()));
      await tester.pump();
      expect(find.byType(ResetPasswordSuccessScreen), findsOneWidget);
      expect(find.text('¡Contraseña actualizada!'), findsOneWidget);
      expect(find.text('Ir al inicio de sesión'), findsOneWidget);
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

    testWidgets(
      'CreateCredentialsScreen muestra la sección de verificación de identidad',
      (tester) async {
        await tester.pumpWidget(_wrap(const CreateCredentialsScreen()));
        await tester.pump();
        expect(find.text('Verificá tu identidad'), findsOneWidget);
        expect(find.byType(DocumentCaptureField), findsOneWidget);
      },
    );

    testWidgets(
      'CreateCredentialsScreen deshabilita "Crear credenciales" sin foto de '
      'documento',
      (tester) async {
        await tester.pumpWidget(_wrap(const CreateCredentialsScreen()));
        await tester.pump();
        final boton = tester.widget<PrimaryButton>(
          find.widgetWithText(PrimaryButton, 'Crear credenciales'),
        );
        expect(boton.onPressed, isNull);
      },
    );

    testWidgets('AccountCreatedScreen monta sin errores', (tester) async {
      await tester.pumpWidget(_wrap(const AccountCreatedScreen()));
      await tester.pump();
      // ZoomIn de animate_do tiene timer de animacion; drenamos para evitar timers pendientes.
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(AccountCreatedScreen), findsOneWidget);
    });

    testWidgets('AccountCreatedScreen muestra texto "Email verificado"', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const AccountCreatedScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Email verificado'), findsOneWidget);
    });

    testWidgets('AccountCreatedScreen muestra botón "Ir al login"', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const AccountCreatedScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Ir al login'), findsOneWidget);
    });

    testWidgets('VerifyEmailScreen monta sin errores', (tester) async {
      await tester.pumpWidget(
        _wrap(const VerifyEmailScreen(email: 'test@example.com')),
      );
      await tester.pump();
      expect(find.byType(VerifyEmailScreen), findsOneWidget);
    });

    testWidgets('VerifyEmailScreen muestra el email y el botón Verificar', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const VerifyEmailScreen(email: 'test@example.com')),
      );
      await tester.pump();
      expect(find.textContaining('test@example.com'), findsOneWidget);
      expect(find.text('Verificar'), findsOneWidget);
    });

    testWidgets('VerifyEmailScreen muestra "Reenviar" habilitado al entrar', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const VerifyEmailScreen(email: 'test@example.com')),
      );
      await tester.pump();
      expect(find.textContaining('Reenviar código'), findsOneWidget);
    });
  });
}
