import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:animate_do/animate_do.dart';
import 'package:care_well_app/config/theme/app_theme.dart';
import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/domain/repositories/repositories.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/screens/profile/profile_screen.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fake de [PersonaRepository] que registra las personas actualizadas.
class _FakePersonaRepository implements PersonaRepository {
  final actualizaciones = <Persona>[];

  Persona? get actualizada =>
      actualizaciones.isEmpty ? null : actualizaciones.last;

  @override
  Future<Persona> actualizar(Persona persona) async {
    actualizaciones.add(persona);
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
  @override
  Future<Usuario> login(String email, String contrasena) async => _testUsuario;

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

/// Bytes de una foto de perfil "existente" en el backend: un PNG de 1x1
/// transparente, para que el avatar pueda decodificarla de verdad.
final _fotoExistente = Uint8List.fromList(
  base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
  ),
);

/// Estado de la sesión: por defecto, usuario logueado.
enum _Sesion { logueada, cargando, error, sinUsuario }

/// Estado del rol en el sistema.
enum _Rol { responsable, sinRol, cargando, error }

Widget _wrap({
  _Sesion sesion = _Sesion.logueada,
  _Rol rol = _Rol.responsable,
  Uint8List? imagen,
  PersonaRepository? personaRepository,
  StatsPerfil stats = const StatsPerfil(aCargo: 2, colaboro: 3, edad: 40),
}) {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
      personaRepositoryProvider.overrideWithValue(
        personaRepository ?? _FakePersonaRepository(),
      ),
      personaImagenProvider.overrideWith((ref, id) async => imagen),
      statsPerfilProvider.overrideWith((ref) async => stats),
      rolEnSistemaProvider.overrideWith((ref) async {
        return switch (rol) {
          _Rol.responsable => RolEnSistema.responsable,
          _Rol.sinRol => null,
          _Rol.error => throw Exception('sin asignaciones'),
          // Nunca completa: deja el provider en loading.
          _Rol.cargando => Completer<RolEnSistema?>().future,
        };
      }),
      authStateProvider.overrideWith((ref) {
        final notifier = AuthNotifier(ref.watch(authRepositoryProvider));
        notifier.state = switch (sesion) {
          _Sesion.logueada => AsyncValue.data(_testUsuario),
          _Sesion.cargando => const AsyncValue.loading(),
          _Sesion.error => AsyncValue.error('falló', StackTrace.empty),
          _Sesion.sinUsuario => const AsyncValue.data(null),
        };
        return notifier;
      }),
    ],
    child: MaterialApp(theme: AppTheme().light, home: const ProfileScreen()),
  );
}

/// Viewport de teléfono alto: con el de 800x600 por defecto los grupos de
/// abajo no llegan a construirse.
void _usarViewportTelefono(WidgetTester tester) {
  tester.view.physicalSize = const Size(400, 1000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

/// Monta la pantalla y deja correr el stagger de entrada.
Future<void> _pumpPerfil(
  WidgetTester tester, {
  _Sesion sesion = _Sesion.logueada,
  _Rol rol = _Rol.responsable,
  Uint8List? imagen,
  PersonaRepository? personaRepository,
  StatsPerfil stats = const StatsPerfil(aCargo: 2, colaboro: 3, edad: 40),
}) async {
  _usarViewportTelefono(tester);
  await tester.pumpWidget(
    _wrap(
      sesion: sesion,
      rol: rol,
      imagen: imagen,
      personaRepository: personaRepository,
      stats: stats,
    ),
  );
  await tester.pumpAndSettle();
}

/// Deja visible un elemento que puede quedar bajo el fold.
Future<void> _asegurarVisible(WidgetTester tester, Finder finder) async {
  if (tester.any(finder)) return;
  await tester.scrollUntilVisible(
    finder,
    80,
    scrollable: find.byType(Scrollable).first,
    maxScrolls: 30,
  );
}

void main() {
  group('ProfileScreen · lectura', () {
    testWidgets('muestra los datos del usuario', (tester) async {
      await _pumpPerfil(tester);

      expect(find.text('María García'), findsOneWidget);
      expect(find.text('maria.garcia@example.com'), findsOneWidget);
      expect(find.text('+54 9 11 1234-5678'), findsOneWidget);
      expect(find.text('28456789'), findsOneWidget);
      expect(find.text('15/03/1985'), findsOneWidget);
    });

    testWidgets('muestra el rol una sola vez, en el chip del encabezado', (
      tester,
    ) async {
      await _pumpPerfil(tester);

      expect(find.text('Responsable'), findsOneWidget);
      // La fila "Rol en el sistema" desapareció: el chip la reemplaza.
      expect(find.text('Rol en el sistema'), findsNothing);
    });

    testWidgets('muestra las cifras del perfil', (tester) async {
      await _pumpPerfil(tester);

      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('40'), findsOneWidget);
    });

    testWidgets('el encabezado no ofrece un lápiz en la barra superior', (
      tester,
    ) async {
      await _pumpPerfil(tester);

      expect(find.byTooltip('Editar perfil'), findsNothing);
      expect(find.text('Mi perfil'), findsOneWidget);
    });

    testWidgets('sin rol el encabezado no reserva lugar para el chip', (
      tester,
    ) async {
      await _pumpPerfil(tester, rol: _Rol.sinRol);

      expect(find.byKey(const Key('rol-chip-placeholder')), findsNothing);
      expect(find.text('Responsable'), findsNothing);
    });

    testWidgets('con el rol en error tampoco se reserva lugar', (tester) async {
      await _pumpPerfil(tester, rol: _Rol.error);

      expect(find.byKey(const Key('rol-chip-placeholder')), findsNothing);
    });

    testWidgets('mientras el rol carga se reserva el lugar del chip', (
      tester,
    ) async {
      _usarViewportTelefono(tester);
      await tester.pumpWidget(_wrap(rol: _Rol.cargando));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('rol-chip-placeholder')), findsOneWidget);
    });

    testWidgets('sin sesión activa no muestra datos personales', (
      tester,
    ) async {
      await _pumpPerfil(tester, sesion: _Sesion.sinUsuario);

      expect(find.text('María García'), findsNothing);
    });

    testWidgets('el skeleton es estático: pumpAndSettle no queda colgado', (
      tester,
    ) async {
      await _pumpPerfil(tester, sesion: _Sesion.cargando);

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('María García'), findsNothing);
    });

    testWidgets('ante un error muestra el banner con reintento', (
      tester,
    ) async {
      await _pumpPerfil(tester, sesion: _Sesion.error);

      expect(find.byType(InlineErrorBanner), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
    });

    testWidgets('con animaciones desactivadas no monta el stagger', (
      tester,
    ) async {
      _usarViewportTelefono(tester);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
            personaRepositoryProvider.overrideWithValue(
              _FakePersonaRepository(),
            ),
            personaImagenProvider.overrideWith((ref, id) async => null),
            statsPerfilProvider.overrideWith(
              (ref) async =>
                  const StatsPerfil(aCargo: 0, colaboro: 0, edad: 40),
            ),
            rolEnSistemaProvider.overrideWith(
              (ref) async => RolEnSistema.responsable,
            ),
            authStateProvider.overrideWith((ref) {
              final notifier = AuthNotifier(ref.watch(authRepositoryProvider));
              notifier.state = AsyncValue.data(_testUsuario);
              return notifier;
            }),
          ],
          child: MaterialApp(
            theme: AppTheme().light,
            home: const MediaQuery(
              data: MediaQueryData(disableAnimations: true),
              child: ProfileScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FadeInUp), findsNothing);
      expect(find.text('María García'), findsOneWidget);
    });
  });

  group('ProfileScreen · edición inline', () {
    testWidgets('el Email se muestra en solo lectura (sin botón de editar)', (
      tester,
    ) async {
      await _pumpPerfil(tester);

      expect(find.text('maria.garcia@example.com'), findsOneWidget);
      expect(find.byTooltip('Editar Email'), findsNothing);
    });

    testWidgets(
      'guardar teléfono invoca PersonaRepository.actualizar con la persona '
      'completa y refresca la sesión',
      (tester) async {
        final repo = _FakePersonaRepository();
        await _pumpPerfil(tester, personaRepository: repo);

        await _asegurarVisible(tester, find.byTooltip('Editar Teléfono'));
        await tester.tap(find.byTooltip('Editar Teléfono'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), '+54 9 11 9999-0000');
        await tester.pump();

        await tester.tap(find.byTooltip('Guardar'));
        await tester.pumpAndSettle();

        expect(repo.actualizada, isNotNull);
        expect(repo.actualizada!.id, _testUsuario.persona.id);
        expect(repo.actualizada!.telefono, '+54 9 11 9999-0000');
        expect(repo.actualizada!.documento, _testUsuario.persona.documento);
        expect(repo.actualizada!.nombre, _testUsuario.persona.nombre);

        // La sesión refleja el nuevo teléfono.
        expect(find.text('+54 9 11 9999-0000'), findsOneWidget);
      },
    );

    testWidgets(
      'guardar un campo NO borra la foto de perfil: reenvía la existente',
      (tester) async {
        // El backend reemplaza `Imagen` incondicionalmente: si el PUT viaja sin
        // foto, la foto se pierde. Este test es la red que lo impide.
        final repo = _FakePersonaRepository();
        await _pumpPerfil(
          tester,
          personaRepository: repo,
          imagen: _fotoExistente,
        );

        await _asegurarVisible(tester, find.byTooltip('Editar Teléfono'));
        await tester.tap(find.byTooltip('Editar Teléfono'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), '+54 9 11 9999-0000');
        await tester.pump();
        await tester.tap(find.byTooltip('Guardar'));
        await tester.pumpAndSettle();

        expect(repo.actualizada, isNotNull);
        expect(repo.actualizada!.imagen, isNotNull);
        expect(repo.actualizada!.imagen, base64Encode(_fotoExistente));
      },
    );

    testWidgets('guardar el DNI persiste el nuevo documento', (tester) async {
      final repo = _FakePersonaRepository();
      await _pumpPerfil(tester, personaRepository: repo);

      await _asegurarVisible(tester, find.byTooltip('Editar DNI'));
      await tester.tap(find.byTooltip('Editar DNI'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '30111222');
      await tester.pump();
      await tester.tap(find.byTooltip('Guardar'));
      await tester.pumpAndSettle();

      expect(repo.actualizada!.documento, '30111222');
    });

    testWidgets('un DNI inválido no llega al repositorio', (tester) async {
      final repo = _FakePersonaRepository();
      await _pumpPerfil(tester, personaRepository: repo);

      await _asegurarVisible(tester, find.byTooltip('Editar DNI'));
      await tester.tap(find.byTooltip('Editar DNI'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '123');
      await tester.pump();
      await tester.tap(find.byTooltip('Guardar'));
      await tester.pumpAndSettle();

      expect(repo.actualizaciones, isEmpty);
      expect(find.text('Ingresá un DNI válido (7-8 dígitos).'), findsOneWidget);
    });
  });

  group('ProfileScreen · nombre y apellido', () {
    testWidgets('tocar el nombre abre la hoja de edición', (tester) async {
      await _pumpPerfil(tester);

      await tester.tap(find.text('María García'));
      await tester.pumpAndSettle();

      expect(find.text('Nombre y apellido'), findsOneWidget);
    });

    testWidgets('guardar en la hoja hace un solo PUT con los dos campos', (
      tester,
    ) async {
      final repo = _FakePersonaRepository();
      await _pumpPerfil(tester, personaRepository: repo);

      await tester.tap(find.text('María García'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'Ana');
      await tester.enterText(find.byType(TextFormField).last, 'Pérez');
      await tester.pump();
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      expect(repo.actualizaciones, hasLength(1));
      expect(repo.actualizada!.nombre, 'Ana');
      expect(repo.actualizada!.apellido, 'Pérez');
      expect(find.text('Ana Pérez'), findsOneWidget);
    });

    testWidgets('sin cambios reales la hoja no dispara ningún guardado', (
      tester,
    ) async {
      final repo = _FakePersonaRepository();
      await _pumpPerfil(tester, personaRepository: repo);

      await tester.tap(find.text('María García'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      expect(repo.actualizaciones, isEmpty);
    });
  });

  group('ProfileScreen · foto', () {
    testWidgets('con foto, tocar el avatar abre el visor', (tester) async {
      await _pumpPerfil(tester, imagen: _fotoExistente);

      await tester.tap(find.byType(Avatar));
      await tester.pumpAndSettle();

      expect(find.byType(InteractiveViewer), findsOneWidget);
    });

    testWidgets('sin foto, tocar el avatar abre el selector de origen', (
      tester,
    ) async {
      await _pumpPerfil(tester);

      await tester.tap(find.byType(Avatar));
      await tester.pumpAndSettle();

      expect(find.text('Tomar foto'), findsOneWidget);
      expect(find.text('Elegir de galería'), findsOneWidget);
    });

    testWidgets('el badge abre el selector de origen aunque haya foto', (
      tester,
    ) async {
      await _pumpPerfil(tester, imagen: _fotoExistente);

      await tester.tap(find.byKey(ProfileHeroAvatar.badgeKey));
      await tester.pumpAndSettle();

      expect(find.text('Tomar foto'), findsOneWidget);
    });
  });
}
