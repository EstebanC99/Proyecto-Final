import 'dart:typed_data';

import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/domain/repositories/repositories.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/screens/profile/profile_edit_screen.dart';
import 'package:care_well_app/presentation/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fake de [PersonaRepository] que registra la última persona actualizada.
class _FakePersonaRepository implements PersonaRepository {
  Persona? actualizada;

  @override
  Future<Persona> actualizar(Persona persona) async {
    actualizada = persona;
    return persona;
  }

  @override
  Future<Uint8List?> getImagen(int id) async => null;

  @override
  Future<Persona> getById(int id) => throw UnimplementedError();

  @override
  Future<List<Persona>> getDependientesByUsuario(int usuarioId) =>
      throw UnimplementedError();

  @override
  Future<Persona> crear(Persona persona) => throw UnimplementedError();

  @override
  Future<void> eliminar(int id) => throw UnimplementedError();
}

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
      personaImagenProvider.overrideWith((ref, id) async => null),
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
            personaImagenProvider.overrideWith((ref, id) async => null),
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
            personaImagenProvider.overrideWith((ref, id) async => null),
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

  group('ProfileEditScreen', () {
    testWidgets('el Email se muestra en solo lectura (sin botón de editar)', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(
              _FakeAuthRepository(_testUsuario),
            ),
            personaImagenProvider.overrideWith((ref, id) async => null),
            personaRepositoryProvider.overrideWithValue(
              _FakePersonaRepository(),
            ),
            authStateProvider.overrideWith((ref) {
              final notifier = AuthNotifier(ref.watch(authRepositoryProvider));
              notifier.state = AsyncValue.data(_testUsuario);
              return notifier;
            }),
          ],
          child: const MaterialApp(home: ProfileEditScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('maria.garcia@example.com'), findsOneWidget);
      // El Email no expone acción de edición.
      expect(find.byTooltip('Editar Email'), findsNothing);
    });

    testWidgets(
      'guardar teléfono invoca PersonaRepository.actualizar con la persona '
      'completa y refresca la sesión',
      (tester) async {
        final fakeRepo = _FakePersonaRepository();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authRepositoryProvider.overrideWithValue(
                _FakeAuthRepository(_testUsuario),
              ),
              personaImagenProvider.overrideWith((ref, id) async => null),
              personaRepositoryProvider.overrideWithValue(fakeRepo),
              authStateProvider.overrideWith((ref) {
                final notifier = AuthNotifier(
                  ref.watch(authRepositoryProvider),
                );
                notifier.state = AsyncValue.data(_testUsuario);
                return notifier;
              }),
            ],
            child: const MaterialApp(home: ProfileEditScreen()),
          ),
        );
        await tester.pump();

        // Activar edición del teléfono (la fila puede quedar fuera del
        // viewport de test: se asegura su visibilidad antes de tocar).
        await tester.ensureVisible(find.byTooltip('Editar Teléfono'));
        await tester.tap(find.byTooltip('Editar Teléfono'));
        await tester.pump();

        // Escribir el nuevo teléfono.
        await tester.enterText(find.byType(TextField), '+54 9 11 9999-0000');
        await tester.pump();

        // Confirmar el guardado.
        await tester.ensureVisible(find.byTooltip('Guardar'));
        await tester.tap(find.byTooltip('Guardar'));
        await tester.pumpAndSettle();

        // El repositorio recibió la persona completa con el nuevo teléfono.
        expect(fakeRepo.actualizada, isNotNull);
        expect(fakeRepo.actualizada!.id, _testUsuario.persona.id);
        expect(fakeRepo.actualizada!.telefono, '+54 9 11 9999-0000');
        expect(fakeRepo.actualizada!.documento, _testUsuario.persona.documento);
        expect(fakeRepo.actualizada!.nombre, _testUsuario.persona.nombre);

        // La sesión refleja el nuevo teléfono.
        expect(find.text('+54 9 11 9999-0000'), findsOneWidget);
      },
    );
  });
}
