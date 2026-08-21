import 'package:care_well_app/config/theme/app_theme.dart';
import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/domain/exceptions/exceptions.dart';
import 'package:care_well_app/domain/repositories/repositories.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/screens/settings/change_password_screen.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Repositorio de prueba: registra lo que recibe y deja inyectar el desenlace
/// del cambio de contraseña (éxito, `Exception` de negocio o `Error` técnico).
class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.alCambiar});

  /// Se ejecuta dentro de `cambiarContrasena`. Puede lanzar para simular la
  /// falla que se quiera probar.
  final void Function()? alCambiar;

  int llamadas = 0;
  int? usuarioIdRecibido;
  String? actualRecibida;
  String? nuevaRecibida;

  static final _usuario = Usuario(
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
    estado: EstadoUsuario(
      id: EstadosUsuarioConst.activo,
      descripcion: 'Activo',
    ),
  );

  @override
  Future<void> cambiarContrasena({
    required int usuarioId,
    required String contrasenaActual,
    required String contrasenaNueva,
  }) async {
    llamadas++;
    usuarioIdRecibido = usuarioId;
    actualRecibida = contrasenaActual;
    nuevaRecibida = contrasenaNueva;
    alCambiar?.call();
  }

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
  Future<void> crearCredenciales({
    required String email,
    required String contrasena,
    required String imagenDocumento,
  }) async {}
}

/// Monta la pantalla como ruta apilada, para que el `pop` del guard tenga a
/// dónde volver (en la app se abre con `pushNamed` desde Configuración).
Future<_FakeAuthRepository> _pushScreen(
  WidgetTester tester, {
  void Function()? alCambiar,
}) async {
  final repo = _FakeAuthRepository(alCambiar: alCambiar);
  final navKey = GlobalKey<NavigatorState>();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(repo),
        authStateProvider.overrideWith((ref) {
          final notifier = AuthNotifier(ref.watch(authRepositoryProvider));
          notifier.state = AsyncValue.data(_FakeAuthRepository._usuario);
          return notifier;
        }),
      ],
      child: MaterialApp(
        navigatorKey: navKey,
        theme: AppTheme().light,
        home: const Scaffold(body: Center(child: Text('pantalla anterior'))),
      ),
    ),
  );

  navKey.currentState!.push(
    MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
  );
  await tester.pumpAndSettle();
  return repo;
}

/// Dispara el gesto de "atrás" del sistema.
Future<void> _volverAtras(WidgetTester tester) async {
  final dynamic widgetsAppState = tester.state(find.byType(WidgetsApp));
  await widgetsAppState.didPopRoute();
  await tester.pumpAndSettle();
}

Finder get _campos => find.byType(TextField);

FilledButton _cta(WidgetTester tester) =>
    tester.widget<FilledButton>(find.byType(FilledButton));

/// Completa los tres campos del formulario.
Future<void> _completar(
  WidgetTester tester, {
  required String actual,
  required String nueva,
  String? confirmar,
}) async {
  await tester.enterText(_campos.at(0), actual);
  await tester.enterText(_campos.at(1), nueva);
  await tester.enterText(_campos.at(2), confirmar ?? nueva);
  await tester.pumpAndSettle();
}

Future<void> _guardar(WidgetTester tester) async {
  await tester.tap(find.text('Guardar cambios'));
  await tester.pumpAndSettle();
}

void main() {
  group('ChangePasswordScreen · armazón', () {
    testWidgets('muestra los tres campos con su rótulo y el CTA al pie', (
      tester,
    ) async {
      await _pushScreen(tester);

      expect(_campos, findsNWidgets(3));
      // Rótulos en versalitas (SectionLabel), el lenguaje de los formularios.
      expect(find.byType(SectionLabel), findsNWidgets(3));
      expect(find.text('CONTRASEÑA ACTUAL *'), findsOneWidget);
      expect(find.text('NUEVA CONTRASEÑA *'), findsOneWidget);
      expect(find.text('CONFIRMAR NUEVA CONTRASEÑA *'), findsOneWidget);
      expect(find.text('Actualizá tu contraseña'), findsOneWidget);
      expect(find.byType(FormBottomBar), findsOneWidget);
      expect(find.text('Guardar cambios'), findsOneWidget);
    });

    testWidgets('el medidor de fortaleza aparece recién al escribir', (
      tester,
    ) async {
      await _pushScreen(tester);

      expect(find.byType(PasswordStrengthMeter), findsNothing);

      await tester.enterText(_campos.at(1), 'Password1');
      await tester.pumpAndSettle();

      expect(find.byType(PasswordStrengthMeter), findsOneWidget);
      expect(find.text('Fuerte'), findsOneWidget);
    });
  });

  group('ChangePasswordScreen · validación', () {
    testWidgets('con todo vacío muestra los tres errores y no llama al repo', (
      tester,
    ) async {
      final repo = await _pushScreen(tester);

      await _guardar(tester);

      expect(find.text('Ingresá tu contraseña actual.'), findsOneWidget);
      expect(find.text('Ingresá una contraseña.'), findsOneWidget);
      expect(find.text('Confirmá tu contraseña.'), findsOneWidget);
      expect(repo.llamadas, 0);
    });

    testWidgets(
      'una contraseña nueva de menos de 8 caracteres no llega al repositorio',
      (tester) async {
        // La misma exigencia que rige en el alta de la cuenta.
        final repo = await _pushScreen(tester);

        await _completar(tester, actual: '1234', nueva: 'Corta1');
        await _guardar(tester);

        expect(
          find.text('La contraseña debe tener al menos 8 caracteres.'),
          findsOneWidget,
        );
        expect(repo.llamadas, 0);
        expect(find.text('Contraseña actualizada'), findsNothing);
      },
    );

    testWidgets('la contraseña actual vacía no llega al repositorio', (
      tester,
    ) async {
      final repo = await _pushScreen(tester);

      await _completar(tester, actual: '', nueva: 'Password1');
      await _guardar(tester);

      expect(find.text('Ingresá tu contraseña actual.'), findsOneWidget);
      expect(repo.llamadas, 0);
    });

    testWidgets('la confirmación que no coincide muestra el error', (
      tester,
    ) async {
      final repo = await _pushScreen(tester);

      await _completar(
        tester,
        actual: '1234',
        nueva: 'Password1',
        confirmar: 'Password2',
      );
      await _guardar(tester);

      expect(find.text('Las contraseñas no coinciden.'), findsOneWidget);
      expect(repo.llamadas, 0);
    });

    testWidgets('el foco va al primer campo con problema', (tester) async {
      await _pushScreen(tester);

      // Sólo falla la nueva: el foco tiene que saltar al segundo campo.
      await _completar(tester, actual: '1234', nueva: 'corta');
      await _guardar(tester);

      final nueva = tester.widget<TextField>(_campos.at(1));
      expect(nueva.focusNode?.hasFocus, isTrue);
    });

    testWidgets('escribir limpia el error del campo', (tester) async {
      await _pushScreen(tester);

      await _guardar(tester);
      expect(find.text('Ingresá tu contraseña actual.'), findsOneWidget);

      await tester.enterText(_campos.at(0), '1234');
      await tester.pumpAndSettle();

      expect(find.text('Ingresá tu contraseña actual.'), findsNothing);
    });
  });

  group('ChangePasswordScreen · guardado', () {
    testWidgets('el camino feliz manda los valores y muestra el éxito', (
      tester,
    ) async {
      final repo = await _pushScreen(tester);

      await _completar(tester, actual: '1234', nueva: 'Password1');
      await _guardar(tester);

      expect(repo.llamadas, 1);
      expect(repo.usuarioIdRecibido, 101);
      expect(repo.actualRecibida, '1234');
      expect(repo.nuevaRecibida, 'Password1');

      expect(find.byType(SuccessView), findsOneWidget);
      expect(find.text('Contraseña actualizada'), findsOneWidget);
      expect(find.text('Volver a Configuración'), findsOneWidget);
    });

    testWidgets('la contraseña actual incorrecta se muestra en su campo', (
      tester,
    ) async {
      await _pushScreen(
        tester,
        alCambiar: () => throw Exception('La contraseña actual es incorrecta.'),
      );

      await _completar(tester, actual: 'incorrecta', nueva: 'Password1');
      await _guardar(tester);

      expect(find.text('Contraseña incorrecta'), findsOneWidget);
      expect(find.text('Contraseña actualizada'), findsNothing);
      expect(find.byType(ChangePasswordScreen), findsOneWidget);
    });

    testWidgets(
      'un Error del datasource libera el CTA y avisa sin tecnicismos',
      (tester) async {
        // El endpoint todavía no existe: `ApiAuthDatasource` lanza
        // `UnimplementedError`, que es un `Error` y no una `Exception`.
        await _pushScreen(
          tester,
          alCambiar: () => throw UnimplementedError(
            'TODO: endpoint de cambio de contraseña pendiente en el backend.',
          ),
        );

        await _completar(tester, actual: '1234', nueva: 'Password1');
        await _guardar(tester);

        expect(
          find.text('No pudimos cambiar tu contraseña. Intentá de nuevo.'),
          findsOneWidget,
        );
        expect(find.textContaining('TODO'), findsNothing);
        // El CTA vuelve a estar disponible: nada de spinner colgado.
        expect(_cta(tester).onPressed, isNotNull);
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.byType(ChangePasswordScreen), findsOneWidget);
      },
    );

    testWidgets('sin conexión muestra su propio mensaje', (tester) async {
      await _pushScreen(
        tester,
        alCambiar: () => throw const SinConexionException(),
      );

      await _completar(tester, actual: '1234', nueva: 'Password1');
      await _guardar(tester);

      expect(
        find.text('Sin conexión. Verificá tu red e intentá de nuevo.'),
        findsOneWidget,
      );
      expect(_cta(tester).onPressed, isNotNull);
    });
  });

  group('ChangePasswordScreen · salida', () {
    testWidgets('con los campos vacíos el atrás sale sin preguntar', (
      tester,
    ) async {
      await _pushScreen(tester);

      await _volverAtras(tester);

      expect(find.text('Tenés cambios sin guardar'), findsNothing);
      expect(find.text('pantalla anterior'), findsOneWidget);
    });

    testWidgets('con algo escrito el atrás pide confirmación', (tester) async {
      await _pushScreen(tester);

      await tester.enterText(_campos.at(0), '1234');
      await tester.pumpAndSettle();
      await _volverAtras(tester);

      expect(find.text('Tenés cambios sin guardar'), findsOneWidget);
      expect(find.text('pantalla anterior'), findsNothing);
    });

    testWidgets('después del éxito el atrás no pregunta nada', (tester) async {
      await _pushScreen(tester);

      await _completar(tester, actual: '1234', nueva: 'Password1');
      await _guardar(tester);
      expect(find.byType(SuccessView), findsOneWidget);

      await _volverAtras(tester);

      expect(find.text('Tenés cambios sin guardar'), findsNothing);
      expect(find.text('pantalla anterior'), findsOneWidget);
    });
  });
}
