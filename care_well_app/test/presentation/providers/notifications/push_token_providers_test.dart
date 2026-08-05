import 'dart:async';

import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/domain/repositories/repositories.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../_fakes/fake_dispositivo_repository.dart';
import '../../../_fakes/fake_push_messaging_service.dart';
import '../../../_fakes/test_fixtures.dart';

const _tokenInicial = 'fid-abc:token-inicial';
const _tokenRotado = 'fid-abc:token-rotado';

final _persona = Persona(
  id: 1,
  nombre: 'Esteban',
  apellido: 'C.',
  documento: '40111222',
  fechaNacimiento: DateTime(1999, 1, 1),
  email: 'esteban@mail.com',
);

final _usuario = Usuario(
  id: 101,
  persona: _persona,
  contrasena: '1234',
  estado: estadoUsuarioActivo,
);

/// Fake de [AuthRepository] con lo mínimo para login/logout.
class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.log});

  final List<String>? log;

  @override
  Future<Usuario> login(String email, String contrasena) async => _usuario;

  @override
  Future<void> logout() async => log?.add('logout');

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

/// Arma un contenedor con los tres fakes inyectados.
({
  ProviderContainer container,
  FakePushMessagingService push,
  FakeDispositivoRepository dispositivos,
})
_crearContainer({String? token = _tokenInicial, List<String>? log}) {
  final push = FakePushMessagingService(token: token);
  final dispositivos = FakeDispositivoRepository(log: log);

  final container = ProviderContainer(
    overrides: [
      pushMessagingServiceProvider.overrideWithValue(push),
      dispositivoRepositoryProvider.overrideWithValue(dispositivos),
      authRepositoryProvider.overrideWithValue(_FakeAuthRepository(log: log)),
    ],
  );
  addTearDown(container.dispose);
  addTearDown(push.dispose);

  return (container: container, push: push, dispositivos: dispositivos);
}

void main() {
  group('PushTokenSynchronizer', () {
    test('registra el token del dispositivo como plataforma Android', () async {
      final ctx = _crearContainer();

      await ctx.container
          .read(pushTokenSynchronizerProvider)
          .registrarDispositivo();

      expect(ctx.push.permisoSolicitado, isTrue);
      expect(ctx.dispositivos.registrados, hasLength(1));
      expect(ctx.dispositivos.registrados.single.token, _tokenInicial);
      expect(
        ctx.dispositivos.registrados.single.plataforma,
        PlataformasDispositivoConst.android,
      );
    });

    test('no registra nada si el proveedor no devuelve token', () async {
      final ctx = _crearContainer(token: null);

      await ctx.container
          .read(pushTokenSynchronizerProvider)
          .registrarDispositivo();

      expect(ctx.dispositivos.registrados, isEmpty);
    });

    test('la baja elimina el token vigente del dispositivo', () async {
      final ctx = _crearContainer();

      await ctx.container
          .read(pushTokenSynchronizerProvider)
          .darDeBajaDispositivo();

      expect(ctx.dispositivos.eliminados, [_tokenInicial]);
    });

    test('la baja espera a que termine el alta en curso', () async {
      final log = <String>[];
      final ctx = _crearContainer(log: log);
      final altaPendiente = Completer<void>();
      ctx.dispositivos.registrarPendiente = altaPendiente;

      final synchronizer = ctx.container.read(pushTokenSynchronizerProvider);

      // El alta es fire-and-forget: queda pendiente en el backend.
      final alta = synchronizer.registrarDispositivo();
      final baja = synchronizer.darDeBajaDispositivo();
      await pumpEventQueue();

      // Mientras el alta no resuelva, la baja no puede haber llegado.
      expect(log, isEmpty);

      altaPendiente.complete();
      await Future.wait([alta, baja]);

      // Si se invirtiera, el backend reactivaría un dispositivo sin sesión.
      expect(log, ['registrar', 'eliminar']);
    });

    test('la baja se hace igual si el alta en curso falló', () async {
      final ctx = _crearContainer();
      final altaPendiente = Completer<void>();
      ctx.dispositivos.registrarPendiente = altaPendiente;

      final synchronizer = ctx.container.read(pushTokenSynchronizerProvider);

      final alta = synchronizer.registrarDispositivo();
      final baja = synchronizer.darDeBajaDispositivo();
      // Sin esto el alta todavía no llegó a esperar el completer y el error
      // quedaría sin escuchar.
      await pumpEventQueue();
      altaPendiente.completeError(Exception('sin red'));

      await expectLater(alta, throwsException);
      await baja;

      expect(ctx.dispositivos.eliminados, [_tokenInicial]);
    });
  });

  group('pushTokenRegistrationProvider', () {
    test('no registra el dispositivo mientras no haya sesión', () async {
      final ctx = _crearContainer();
      ctx.container.listen(pushTokenRegistrationProvider, (_, _) {});

      await pumpEventQueue();

      expect(ctx.dispositivos.registrados, isEmpty);
    });

    test('registra el dispositivo al iniciar sesión', () async {
      final ctx = _crearContainer();
      ctx.container.listen(pushTokenRegistrationProvider, (_, _) {});

      await ctx.container
          .read(authStateProvider.notifier)
          .login('esteban@mail.com', '1234');
      // Fuerza el recálculo del provider tras el cambio de sesión.
      ctx.container.read(pushTokenRegistrationProvider);
      await pumpEventQueue();

      expect(ctx.dispositivos.registrados.single.token, _tokenInicial);
    });

    test('re-registra el dispositivo cuando el token rota', () async {
      final ctx = _crearContainer();
      ctx.container.listen(pushTokenRegistrationProvider, (_, _) {});

      await ctx.container
          .read(authStateProvider.notifier)
          .login('esteban@mail.com', '1234');
      ctx.container.read(pushTokenRegistrationProvider);
      await pumpEventQueue();

      ctx.push.rotarToken(_tokenRotado);
      await pumpEventQueue();

      expect(ctx.dispositivos.registrados.map((e) => e.token), [
        _tokenInicial,
        _tokenRotado,
      ]);
    });

    test('deja de escuchar la rotación del token al cerrar sesión', () async {
      final ctx = _crearContainer();
      ctx.container.listen(pushTokenRegistrationProvider, (_, _) {});

      await ctx.container
          .read(authStateProvider.notifier)
          .login('esteban@mail.com', '1234');
      ctx.container.read(pushTokenRegistrationProvider);
      await pumpEventQueue();

      await ctx.container.read(cerrarSesionProvider)();
      ctx.container.read(pushTokenRegistrationProvider);
      await pumpEventQueue();

      ctx.push.rotarToken(_tokenRotado);
      await pumpEventQueue();

      // Solo el alta inicial: sin sesión no se puede registrar (daría 401).
      expect(ctx.dispositivos.registrados.map((e) => e.token), [_tokenInicial]);
    });
  });
}
