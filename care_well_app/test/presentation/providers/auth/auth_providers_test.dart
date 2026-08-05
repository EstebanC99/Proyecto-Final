import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/domain/exceptions/exceptions.dart';
import 'package:care_well_app/domain/repositories/repositories.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../_fakes/fake_dispositivo_repository.dart';
import '../../../_fakes/fake_push_messaging_service.dart';

const _token = 'fid-abc:token-inicial';

// Implementacion manual de AuthRepository para tests, sin dependencias externas.
class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.log});

  /// Log compartido para verificar el ORDEN relativo a otras operaciones.
  final List<String>? log;

  static final _persona = Persona(
    id: 1,
    nombre: 'Test',
    apellido: 'User',
    documento: '28000001',
    fechaNacimiento: DateTime(1990, 1, 1),
    email: 'test@example.com',
    telefono: '+54 9 11 0000-0000',
  );

  static final _usuario = Usuario(
    id: 101,
    persona: _persona,
    contrasena: '1234',
    estado: EstadoUsuario(
      id: EstadosUsuarioConst.activo,
      descripcion: 'Activo',
    ),
  );

  String _contrasenaActual = '1234';

  // Registra las últimas llamadas para verificar delegación en los tests.
  String? reenviarCodigoEmail;
  ({String email, String codigo})? verificarEmailArgs;
  ({String email, String codigo, String contrasenaNueva})?
  confirmarResetContrasenaArgs;

  /// Si se setea, `crearCredenciales` lanza este error (para probar el manejo
  /// de excepciones aguas arriba).
  Object? crearCredencialesError;

  @override
  Future<Usuario> login(String email, String contrasena) async {
    if (email == 'test@example.com' && contrasena == _contrasenaActual) {
      return _usuario;
    }
    throw Exception('Credenciales inválidas.');
  }

  @override
  Future<void> register(RegistroData data) async {}

  @override
  Future<void> solicitarRecuperacionContrasena(String email) async {}

  @override
  Future<void> confirmarResetContrasena({
    required String email,
    required String codigo,
    required String contrasenaNueva,
  }) async {
    confirmarResetContrasenaArgs = (
      email: email,
      codigo: codigo,
      contrasenaNueva: contrasenaNueva,
    );
  }

  @override
  Future<void> reenviarCodigoVerificacion(String email) async {
    reenviarCodigoEmail = email;
  }

  @override
  Future<void> verificarEmail(String email, String codigo) async {
    verificarEmailArgs = (email: email, codigo: codigo);
  }

  @override
  Future<void> logout() async => log?.add('logout');

  @override
  Future<void> eliminarCuenta() async {}

  @override
  Future<void> cambiarContrasena({
    required int usuarioId,
    required String contrasenaActual,
    required String contrasenaNueva,
  }) async {
    if (contrasenaActual != _contrasenaActual) {
      throw Exception('La contraseña actual es incorrecta.');
    }
    _contrasenaActual = contrasenaNueva;
  }

  @override
  Future<void> crearCredenciales({
    required String email,
    required String contrasena,
    required String imagenDocumento,
  }) async {
    if (crearCredencialesError != null) throw crearCredencialesError!;
  }
}

ProviderContainer _buildContainer() => ProviderContainer(
  overrides: [authRepositoryProvider.overrideWithValue(_FakeAuthRepository())],
);

/// Contenedor con los fakes que necesita el cierre de sesión: además del
/// repositorio de auth, el proveedor de push y el repositorio de dispositivos.
({ProviderContainer container, FakeDispositivoRepository dispositivos})
_buildContainerConPush(List<String> log) {
  final push = FakePushMessagingService(token: _token);
  final dispositivos = FakeDispositivoRepository(log: log);

  final container = ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(_FakeAuthRepository(log: log)),
      pushMessagingServiceProvider.overrideWithValue(push),
      dispositivoRepositoryProvider.overrideWithValue(dispositivos),
    ],
  );
  addTearDown(container.dispose);
  addTearDown(push.dispose);

  return (container: container, dispositivos: dispositivos);
}

void main() {
  group('AuthNotifier', () {
    test('estado inicial es AsyncValue.data(null)', () {
      final container = _buildContainer();
      addTearDown(container.dispose);

      final state = container.read(authStateProvider);
      expect(state, const AsyncValue<Usuario?>.data(null));
    });

    test(
      'login con credenciales correctas retorna un Usuario no nulo',
      () async {
        final container = _buildContainer();
        addTearDown(container.dispose);

        await container
            .read(authStateProvider.notifier)
            .login('test@example.com', '1234');

        final state = container.read(authStateProvider);
        expect(state.hasValue, isTrue);
        expect(state.value, isNotNull);
        expect(state.value?.persona.email, 'test@example.com');
      },
    );

    test('logout resetea el estado a AsyncValue.data(null)', () async {
      final container = _buildContainer();
      addTearDown(container.dispose);

      await container
          .read(authStateProvider.notifier)
          .login('test@example.com', '1234');
      await container.read(authStateProvider.notifier).logout();

      final state = container.read(authStateProvider);
      expect(state, const AsyncValue<Usuario?>.data(null));
    });

    test('register completa sin error', () async {
      final container = _buildContainer();
      addTearDown(container.dispose);

      final result = await container
          .read(authStateProvider.notifier)
          .register(
            RegistroData(
              nombre: 'Test',
              apellido: 'User',
              documento: '30123456',
              fechaNacimiento: DateTime(1990, 5, 20),
              email: 'test@example.com',
              contrasena: 'Password1',
              imagenDocumento: 'ZG9jdW1lbnRv',
            ),
          );

      expect(result.hasValue, isTrue);
      expect(result.hasError, isFalse);
    });

    test('register no modifica el estado de sesión', () async {
      final container = _buildContainer();
      addTearDown(container.dispose);

      await container
          .read(authStateProvider.notifier)
          .register(
            RegistroData(
              nombre: 'Test',
              apellido: 'User',
              documento: '30123456',
              fechaNacimiento: DateTime(1990, 5, 20),
              email: 'test@example.com',
              contrasena: 'Password1',
              imagenDocumento: 'ZG9jdW1lbnRv',
            ),
          );

      final sessionState = container.read(authStateProvider);
      expect(sessionState.value, isNull);
    });

    test('crearCredenciales completa sin error', () async {
      final container = _buildContainer();
      addTearDown(container.dispose);

      final result = await container
          .read(authStateProvider.notifier)
          .crearCredenciales(
            email: 'test@example.com',
            contrasena: 'Password1',
            imagenDocumento: 'ZG9jdW1lbnRv',
          );

      expect(result.hasValue, isTrue);
      expect(result.hasError, isFalse);
    });

    test('crearCredenciales no modifica el estado de sesión', () async {
      final container = _buildContainer();
      addTearDown(container.dispose);

      await container
          .read(authStateProvider.notifier)
          .crearCredenciales(
            email: 'test@example.com',
            contrasena: 'Password1',
            imagenDocumento: 'ZG9jdW1lbnRv',
          );

      final sessionState = container.read(authStateProvider);
      expect(sessionState.value, isNull);
    });

    test('crearCredenciales propaga ValidacionException (identidad no válida) '
        'como AsyncValue.error', () async {
      final fake = _FakeAuthRepository()
        ..crearCredencialesError = const ValidacionException(
          'No pudimos validar tu identidad con el documento.',
        );
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(fake)],
      );
      addTearDown(container.dispose);

      final result = await container
          .read(authStateProvider.notifier)
          .crearCredenciales(
            email: 'test@example.com',
            contrasena: 'Password1',
            imagenDocumento: 'ZG9jdW1lbnRv',
          );

      expect(result.hasError, isTrue);
      expect(result.error, isA<ValidacionException>());
    });

    test('crearCredenciales propaga ServicioNoDisponibleException (503) como '
        'AsyncValue.error', () async {
      final fake = _FakeAuthRepository()
        ..crearCredencialesError = const ServicioNoDisponibleException(
          'El servicio no está disponible en este momento.',
        );
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(fake)],
      );
      addTearDown(container.dispose);

      final result = await container
          .read(authStateProvider.notifier)
          .crearCredenciales(
            email: 'test@example.com',
            contrasena: 'Password1',
            imagenDocumento: 'ZG9jdW1lbnRv',
          );

      expect(result.hasError, isTrue);
      expect(result.error, isA<ServicioNoDisponibleException>());
    });

    test('solicitarRecuperacionContrasenaProvider es callable', () async {
      final container = _buildContainer();
      addTearDown(container.dispose);

      final solicitar = container.read(solicitarRecuperacionContrasenaProvider);
      await expectLater(solicitar('test@example.com'), completes);
    });

    test(
      'reenviarCodigoVerificacionProvider delega el email en el repositorio',
      () async {
        final fake = _FakeAuthRepository();
        final container = ProviderContainer(
          overrides: [authRepositoryProvider.overrideWithValue(fake)],
        );
        addTearDown(container.dispose);

        final reenviar = container.read(reenviarCodigoVerificacionProvider);
        await reenviar('test@example.com');

        expect(fake.reenviarCodigoEmail, 'test@example.com');
      },
    );

    test(
      'verificarEmailProvider delega email y código en el repositorio',
      () async {
        final fake = _FakeAuthRepository();
        final container = ProviderContainer(
          overrides: [authRepositoryProvider.overrideWithValue(fake)],
        );
        addTearDown(container.dispose);

        final verificar = container.read(verificarEmailProvider);
        await verificar('test@example.com', '123456');

        expect(fake.verificarEmailArgs?.email, 'test@example.com');
        expect(fake.verificarEmailArgs?.codigo, '123456');
      },
    );

    test(
      'confirmarResetContrasenaProvider delega email, código y contraseña en '
      'el repositorio',
      () async {
        final fake = _FakeAuthRepository();
        final container = ProviderContainer(
          overrides: [authRepositoryProvider.overrideWithValue(fake)],
        );
        addTearDown(container.dispose);

        final confirmar = container.read(confirmarResetContrasenaProvider);
        await confirmar('test@example.com', '123456', 'NuevaClave8');

        expect(fake.confirmarResetContrasenaArgs?.email, 'test@example.com');
        expect(fake.confirmarResetContrasenaArgs?.codigo, '123456');
        expect(
          fake.confirmarResetContrasenaArgs?.contrasenaNueva,
          'NuevaClave8',
        );
      },
    );

    test(
      'cambiarContrasena con contraseña correcta completa sin cambiar sesión',
      () async {
        final container = _buildContainer();
        addTearDown(container.dispose);

        await container
            .read(authStateProvider.notifier)
            .login('test@example.com', '1234');

        await expectLater(
          container
              .read(authStateProvider.notifier)
              .cambiarContrasena(
                contrasenaActual: '1234',
                nuevaContrasena: 'NuevaClave8',
              ),
          completes,
        );

        // La sesión sigue activa.
        final state = container.read(authStateProvider);
        expect(state.value, isNotNull);
        expect(state.value?.id, 101);
      },
    );

    test(
      'cambiarContrasena con contraseña incorrecta lanza excepción',
      () async {
        final container = _buildContainer();
        addTearDown(container.dispose);

        await container
            .read(authStateProvider.notifier)
            .login('test@example.com', '1234');

        await expectLater(
          container
              .read(authStateProvider.notifier)
              .cambiarContrasena(
                contrasenaActual: 'incorrecta',
                nuevaContrasena: 'NuevaClave8',
              ),
          throwsException,
        );
      },
    );

    test(
      'eliminarCuenta limpia el estado de sesión a AsyncValue.data(null)',
      () async {
        final container = _buildContainer();
        addTearDown(container.dispose);

        await container
            .read(authStateProvider.notifier)
            .login('test@example.com', '1234');

        expect(container.read(authStateProvider).value, isNotNull);

        await container.read(authStateProvider.notifier).eliminarCuenta();

        final state = container.read(authStateProvider);
        expect(state, const AsyncValue<Usuario?>.data(null));
      },
    );
  });

  group('cerrarSesionProvider', () {
    test('da de baja el dispositivo ANTES de limpiar la sesión', () async {
      final log = <String>[];
      final ctx = _buildContainerConPush(log);

      await ctx.container
          .read(authStateProvider.notifier)
          .login('test@example.com', '1234');
      await ctx.container.read(cerrarSesionProvider)();

      // El endpoint de baja exige JWT: si se invirtiera el orden, daría 401.
      expect(log, ['eliminar', 'logout']);
      expect(ctx.dispositivos.eliminados, [_token]);
      expect(ctx.container.read(authStateProvider).value, isNull);
    });

    test('cierra la sesión aunque falle la baja del dispositivo', () async {
      final log = <String>[];
      final ctx = _buildContainerConPush(log);
      ctx.dispositivos.fallarAlEliminar = true;

      await ctx.container
          .read(authStateProvider.notifier)
          .login('test@example.com', '1234');
      await ctx.container.read(cerrarSesionProvider)();

      expect(log, ['eliminar', 'logout']);
      expect(ctx.container.read(authStateProvider).value, isNull);
    });
  });
}
