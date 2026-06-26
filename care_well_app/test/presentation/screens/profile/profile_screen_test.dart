import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/domain/repositories/repositories.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/screens/profile/profile_screen.dart';
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

// Usuario demo para los tests.
final _testUsuario = Usuario(
  id: 101,
  persona: Persona(
    id: 1,
    nombre: 'María',
    apellido: 'García',
    documento: '28456789',
    fechaNacimiento: DateTime(1985, 3, 15),
    email: 'maria.garcia@example.com',
    telefono: '+54 9 11 1234-5678',
  ),
  contrasena: '12345678',
  estado: EstadoUsuario(id: EstadosUsuarioConst.activo, descripcion: 'Activo'),
);

Widget _wrap(Widget child, {bool loggedIn = true}) {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(
        _FakeAuthRepository(_testUsuario),
      ),
      if (loggedIn)
        authStateProvider.overrideWith(
          (ref) =>
              AuthNotifier(ref.watch(authRepositoryProvider))
                ..login(_testUsuario.persona.email!, _testUsuario.contrasena),
        ),
    ],
    child: MaterialApp(home: child),
  );
}

void main() {
  group('ProfileScreen', () {
    testWidgets('muestra estado de carga inicialmente', (tester) async {
      await tester.pumpWidget(_wrap(const ProfileScreen()));
      // En el primer frame puede estar en loading.
      await tester.pump();
    });

    testWidgets('muestra los datos del usuario tras cargar', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(
              _FakeAuthRepository(_testUsuario),
            ),
            authStateProvider.overrideWith((ref) {
              final notifier = AuthNotifier(ref.watch(authRepositoryProvider));
              // Injectamos el usuario directamente en el estado.
              notifier.state = AsyncValue.data(_testUsuario);
              return notifier;
            }),
          ],
          child: const MaterialApp(home: ProfileScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('María García'), findsOneWidget);
      expect(find.text('maria.garcia@example.com'), findsOneWidget);
      expect(find.text('+54 9 11 1234-5678'), findsOneWidget);
      expect(find.text('28456789'), findsOneWidget);
    });

    testWidgets('muestra el rol "Responsable"', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
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
          child: const MaterialApp(home: ProfileScreen()),
        ),
      );
      await tester.pump();

      // Al menos un "Responsable" visible (RoleBadge + fila Rol).
      expect(find.text('Responsable'), findsWidgets);
    });

    testWidgets('sin sesión activa no muestra datos personales', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(
              _FakeAuthRepository(_testUsuario),
            ),
          ],
          child: const MaterialApp(home: ProfileScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('María García'), findsNothing);
    });
  });
}
