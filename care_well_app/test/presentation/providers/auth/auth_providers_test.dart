import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/domain/repositories/repositories.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Implementacion manual de AuthRepository para tests, sin dependencias externas.
class _FakeAuthRepository implements AuthRepository {
  static final _persona = Persona(
    id: 1,
    nombre: 'Test',
    apellido: 'User',
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

  @override
  Future<Usuario> login(String email, String contrasena) async {
    if (email == 'test@example.com' && contrasena == _contrasenaActual) {
      return _usuario;
    }
    throw Exception('Credenciales inválidas.');
  }

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
  }) async {
    if (contrasenaActual != _contrasenaActual) {
      throw Exception('La contraseña actual es incorrecta.');
    }
    _contrasenaActual = contrasenaNueva;
  }

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
  }) async {
    final personaActualizada = _usuario.persona.copyWith(
      email: email ?? _usuario.persona.email,
      telefono: telefono ?? _usuario.persona.telefono,
      documento: documento ?? _usuario.persona.documento,
    );
    return _usuario.copyWith(persona: personaActualizada);
  }
}

ProviderContainer _buildContainer() => ProviderContainer(
  overrides: [authRepositoryProvider.overrideWithValue(_FakeAuthRepository())],
);

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
        expect(state.valueOrNull, isNotNull);
        expect(state.valueOrNull?.persona.email, 'test@example.com');
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
            nombre: 'Test',
            apellido: 'User',
            documento: '30123456',
            fechaNacimiento: DateTime(1990, 5, 20),
            email: 'test@example.com',
            contrasena: 'Password1',
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
            nombre: 'Test',
            apellido: 'User',
            documento: '30123456',
            fechaNacimiento: DateTime(1990, 5, 20),
            email: 'test@example.com',
            contrasena: 'Password1',
          );

      final sessionState = container.read(authStateProvider);
      expect(sessionState.valueOrNull, isNull);
    });

    test(
      'crearCredenciales retorna AsyncValue con el usuario creado',
      () async {
        final container = _buildContainer();
        addTearDown(container.dispose);

        final result = await container
            .read(authStateProvider.notifier)
            .crearCredenciales(
              email: 'test@example.com',
              contrasena: 'Password1',
            );

        expect(result.hasValue, isTrue);
        expect(result.valueOrNull?.id, 101);
      },
    );

    test('crearCredenciales no modifica el estado de sesión', () async {
      final container = _buildContainer();
      addTearDown(container.dispose);

      await container
          .read(authStateProvider.notifier)
          .crearCredenciales(
            email: 'test@example.com',
            contrasena: 'Password1',
          );

      final sessionState = container.read(authStateProvider);
      expect(sessionState.valueOrNull, isNull);
    });

    test('solicitarRecuperacionContrasenaProvider es callable', () async {
      final container = _buildContainer();
      addTearDown(container.dispose);

      final solicitar = container.read(solicitarRecuperacionContrasenaProvider);
      await expectLater(solicitar('test@example.com'), completes);
    });

    test(
      'actualizarPerfil actualiza email y refresca el estado de sesión',
      () async {
        final container = _buildContainer();
        addTearDown(container.dispose);

        // Iniciar sesión primero.
        await container
            .read(authStateProvider.notifier)
            .login('test@example.com', '1234');

        await container
            .read(authStateProvider.notifier)
            .actualizarPerfil(email: 'nuevo@example.com');

        final state = container.read(authStateProvider);
        expect(state.hasValue, isTrue);
        expect(state.valueOrNull?.persona.email, 'nuevo@example.com');
      },
    );

    test('actualizarPerfil sin sesión activa no hace nada', () async {
      final container = _buildContainer();
      addTearDown(container.dispose);

      // Sin login previo: state es null.
      await container
          .read(authStateProvider.notifier)
          .actualizarPerfil(email: 'test@example.com');

      final state = container.read(authStateProvider);
      expect(state.valueOrNull, isNull);
    });

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
        expect(state.valueOrNull, isNotNull);
        expect(state.valueOrNull?.id, 101);
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

        expect(container.read(authStateProvider).valueOrNull, isNotNull);

        await container.read(authStateProvider.notifier).eliminarCuenta();

        final state = container.read(authStateProvider);
        expect(state, const AsyncValue<Usuario?>.data(null));
      },
    );
  });
}
