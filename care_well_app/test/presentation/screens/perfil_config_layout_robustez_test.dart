import 'dart:typed_data';

import 'package:animate_do/animate_do.dart';
import 'package:care_well_app/config/constraints/privacy_content.dart';
import 'package:care_well_app/config/theme/app_theme.dart';
import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/domain/repositories/repositories.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/screens/screens.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// `Override` no se reexporta desde el barrel principal en Riverpod 3.
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

/// Robustez de layout de las cuatro pantallas del ciclo de rediseño de Perfil y
/// Configuración: tema claro y oscuro, y escalas tipográficas 1.0 y 2.0, sin
/// overflows.
///
/// Los overflows de Flutter se reportan como excepciones de render, así que
/// alcanza con montar la pantalla y verificar que no se registró ninguna.
///
/// La cobertura de escala y tema ya existía a nivel widget; lo que cierra este
/// archivo es el nivel *pantalla*, donde los widgets compiten por el mismo
/// ancho. Cada caso monta el contenido más exigente posible: nombres y emails
/// largos, cifras de dos dígitos, el banner de error junto al medidor de
/// fortaleza, y el texto legal más largo de la app.
///
/// Lo que estos tests NO detectan es fealdad: que no haya excepción de render
/// no dice que la pantalla se vea bien. Ese juicio es de la verificación visual
/// en dispositivo.

/// Usuario con el nombre y el email más largos que se esperan en producción:
/// es lo que tensa el hero del perfil y la tarjeta de Configuración.
final _usuarioLargo = Usuario(
  id: 101,
  persona: Persona(
    id: 1,
    nombre: 'María Fernanda de los Ángeles',
    apellido: 'Rodríguez Gutiérrez',
    documento: '28000001',
    fechaNacimiento: DateTime(1948, 3, 14),
    email: 'maria.fernanda.rodriguez.gutierrez@correo-largo.com.ar',
    telefono: '+54 9 3624 55-6677',
  ),
  contrasena: '12345678',
  estado: EstadoUsuario(id: EstadosUsuarioConst.activo, descripcion: 'Activo'),
);

/// Cifras de dos dígitos en las tres casillas: el caso ancho de la tarjeta.
const _stats = StatsPerfil(aCargo: 12, colaboro: 34, edad: 78);

/// Repositorio de autenticación de prueba.
///
/// [alCambiar] permite hacer fallar el cambio de contraseña, que es la única
/// forma de dejar visible el `InlineErrorBanner` de la pantalla (el mensaje de
/// error es estado privado, no hay provider que lo inyecte).
class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.alCambiar});

  final void Function()? alCambiar;

  @override
  Future<Usuario> login(String email, String contrasena) async => _usuarioLargo;
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
  }) async {
    alCambiar?.call();
  }

  @override
  Future<void> crearCredenciales({
    required String email,
    required String contrasena,
    required String imagenDocumento,
  }) async {}
}

/// Repositorio de personas de prueba: ningún caso guarda, sólo se monta.
class _FakePersonaRepository implements PersonaRepository {
  @override
  Future<Persona> actualizar(Persona persona) async => persona;
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

/// Overrides comunes: sesión resuelta con el usuario largo, rol y cifras ya
/// disponibles, y versión fija. Ningún caso toca el plugin real de
/// `package_info_plus` ni el backend de imágenes.
List<Override> _overrides({bool cambioFalla = false}) => [
  authRepositoryProvider.overrideWithValue(
    _FakeAuthRepository(
      alCambiar: cambioFalla
          // Mensaje deliberadamente genérico: si dijera "incorrecta" o
          // "actual", la pantalla lo mostraría como error del campo y no como
          // banner, que es justo lo que este archivo quiere tensar.
          ? () => throw Exception('falla del servidor')
          : null,
    ),
  ),
  personaRepositoryProvider.overrideWithValue(_FakePersonaRepository()),
  personaImagenProvider.overrideWith((ref, id) async => null),
  statsPerfilProvider.overrideWith((ref) async => _stats),
  rolEnSistemaProvider.overrideWith((ref) async => RolEnSistema.responsable),
  appVersionProvider.overrideWith((ref) async => '1.2.0'),
  authStateProvider.overrideWith((ref) {
    final notifier = AuthNotifier(ref.watch(authRepositoryProvider));
    notifier.state = AsyncValue.data(_usuarioLargo);
    return notifier;
  }),
];

Widget _app({
  required Widget home,
  required bool oscuro,
  required double escala,
  bool sinAnimaciones = false,
  bool cambioFalla = false,
}) {
  return ProviderScope(
    overrides: _overrides(cambioFalla: cambioFalla),
    child: MaterialApp(
      theme: oscuro ? AppTheme().dark : AppTheme().light,
      home: MediaQuery(
        data: MediaQueryData(
          textScaler: TextScaler.linear(escala),
          disableAnimations: sinAnimaciones,
        ),
        child: home,
      ),
    ),
  );
}

/// Ajusta la superficie de test al tamaño de un teléfono angosto (360×740 dp),
/// que es el caso realista donde el layout puede desbordar. La superficie por
/// defecto (800×600) es más ancha que cualquier teléfono y esconde overflows.
void _usarPantallaDeTelefono(WidgetTester tester) {
  tester.view.physicalSize = const Size(360, 740);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

/// Monta [home] en un teléfono angosto y verifica que no hubo overflows.
///
/// [interaccion] corre sobre el árbol ya montado y antes de la verificación de
/// excepciones: es lo que permite llevar la pantalla al estado exigente cuando
/// ese estado no se puede inyectar por providers (un banner de error, una hoja
/// abierta). [verificaciones] agrega aserciones sobre el árbol final.
void _testDeLayout(
  String descripcion, {
  required Widget home,
  bool oscuro = false,
  double escala = 1.0,
  bool sinAnimaciones = false,
  bool cambioFalla = false,
  Future<void> Function(WidgetTester tester)? interaccion,
  void Function(WidgetTester tester)? verificaciones,
}) {
  testWidgets(descripcion, (tester) async {
    _usarPantallaDeTelefono(tester);
    await tester.pumpWidget(
      _app(
        home: home,
        oscuro: oscuro,
        escala: escala,
        sinAnimaciones: sinAnimaciones,
        cambioFalla: cambioFalla,
      ),
    );
    await tester.pumpAndSettle();

    if (interaccion != null) {
      await interaccion(tester);
      await tester.pumpAndSettle();
    }

    expect(tester.takeException(), isNull);
    verificaciones?.call(tester);
  });
}

/// Pantalla de privacidad tal como la arma el router: es el texto más largo de
/// la app y el que más scroll y saltos de línea genera.
const _politicaDePrivacidad = LegalTextScreen(
  titulo: 'Política de privacidad',
  contenido: kPrivacyContent,
  version: kPrivacyVersion,
  hintScroll: 'Deslizá para leer más',
);

/// Completa los tres campos con una contraseña válida y dispara un guardado que
/// falla: deja a la vez el banner de error y el medidor de fortaleza en
/// pantalla, que es la combinación más alta del formulario.
Future<void> _tipearYFallarElGuardado(WidgetTester tester) async {
  final campos = find.byType(TextField);
  await tester.enterText(campos.at(0), 'ClaveActual1');
  await tester.enterText(campos.at(1), 'NuevaClave123');
  await tester.enterText(campos.at(2), 'NuevaClave123');
  await tester.pumpAndSettle();
  await tester.tap(find.text('Guardar cambios'));
}

/// Abre la hoja de nombre y apellido desde el hero del perfil.
Future<void> _abrirHojaDeNombre(WidgetTester tester) async {
  await tester.tap(find.text(_usuarioLargo.persona.nombreCompleto));
}

/// Abre el diálogo "Acerca de CareWell" desde la sección Legal.
Future<void> _abrirAcercaDe(WidgetTester tester) async {
  final item = find.text('Acerca de CareWell');
  await tester.ensureVisible(item);
  await tester.pumpAndSettle();
  await tester.tap(item);
}

/// Abre el diálogo de eliminación de cuenta desde la sección Zona sensible.
///
/// A diferencia de [_abrirAcercaDe], acá no alcanza con `ensureVisible`: el
/// ítem es el último de la lista y con escala 2.0 queda fuera del viewport y de
/// su `cacheExtent`, así que el `ListView` todavía no lo construyó y ningún
/// finder lo encuentra. Hay que scrollear hasta que exista.
Future<void> _abrirEliminarCuenta(WidgetTester tester) async {
  final item = find.text('Eliminar cuenta');
  if (!tester.any(item)) {
    await tester.scrollUntilVisible(
      item,
      80,
      scrollable: find.byType(Scrollable).first,
      maxScrolls: 30,
    );
  }
  await tester.ensureVisible(item);
  await tester.pumpAndSettle();
  await tester.tap(item);
}

void main() {
  // ── Matriz tema × escala sobre las cuatro pantallas del ciclo ──────────────
  for (final oscuro in [false, true]) {
    final tema = oscuro ? 'oscuro' : 'claro';

    for (final escala in [1.0, 2.0]) {
      _testDeLayout(
        'ProfileScreen renderiza en tema $tema con escala $escala',
        home: const ProfileScreen(),
        oscuro: oscuro,
        escala: escala,
      );

      _testDeLayout(
        'SettingsScreen renderiza en tema $tema con escala $escala',
        home: const SettingsScreen(),
        oscuro: oscuro,
        escala: escala,
      );

      _testDeLayout(
        'ChangePasswordScreen renderiza con error y medidor en tema $tema '
        'con escala $escala',
        home: const ChangePasswordScreen(),
        oscuro: oscuro,
        escala: escala,
        cambioFalla: true,
        interaccion: _tipearYFallarElGuardado,
        // Sin esto el caso podría quedar verde por vacío: si mañana el banner o
        // el medidor dejan de montarse, el test seguiría sin excepciones pero
        // ya no estaría probando lo que dice probar.
        verificaciones: (_) {
          expect(find.byType(InlineErrorBanner), findsOneWidget);
          expect(find.byType(PasswordStrengthMeter), findsOneWidget);
        },
      );

      _testDeLayout(
        'LegalTextScreen renderiza la política de privacidad en tema $tema '
        'con escala $escala',
        home: _politicaDePrivacidad,
        oscuro: oscuro,
        escala: escala,
      );
    }
  }

  // ── Animaciones desactivadas ──────────────────────────────────────────────
  // La rama `sinAnimacion` no consulta el tema: da el mismo árbol en claro y en
  // oscuro, así que alcanza con un tema (el otro ya lo cubre la matriz).
  _testDeLayout(
    'ProfileScreen renderiza sin animaciones',
    home: const ProfileScreen(),
    sinAnimaciones: true,
    verificaciones: (_) => expect(find.byType(FadeInUp), findsNothing),
  );

  _testDeLayout(
    'SettingsScreen renderiza sin animaciones',
    home: const SettingsScreen(),
    sinAnimaciones: true,
    verificaciones: (_) => expect(find.byType(FadeInUp), findsNothing),
  );

  _testDeLayout(
    'ChangePasswordScreen renderiza sin animaciones',
    home: const ChangePasswordScreen(),
    sinAnimaciones: true,
  );

  _testDeLayout(
    'LegalTextScreen renderiza sin animaciones',
    home: _politicaDePrivacidad,
    sinAnimaciones: true,
  );

  // ── Superficies que se abren encima de las pantallas ──────────────────────
  for (final oscuro in [false, true]) {
    final tema = oscuro ? 'oscuro' : 'claro';

    _testDeLayout(
      'la hoja de nombre y apellido renderiza en tema $tema con escala 2.0',
      home: const ProfileScreen(),
      oscuro: oscuro,
      escala: 2.0,
      interaccion: _abrirHojaDeNombre,
      verificaciones: (_) =>
          expect(find.text('Nombre y apellido'), findsOneWidget),
    );

    _testDeLayout(
      'el diálogo Acerca de CareWell renderiza en tema $tema con escala 2.0',
      home: const SettingsScreen(),
      oscuro: oscuro,
      escala: 2.0,
      interaccion: _abrirAcercaDe,
      verificaciones: (_) {
        expect(find.byType(AboutDialog), findsOneWidget);
        // El contenido propio: lo que sí es responsabilidad de la app.
        expect(
          find.textContaining('centraliza la información de la persona'),
          findsOneWidget,
        );
        expect(
          find.text('Contacto: carewell.project.team@gmail.com'),
          findsOneWidget,
        );
      },
    );

    _testDeLayout(
      'el diálogo de eliminar cuenta renderiza en tema $tema con escala 2.0',
      home: const SettingsScreen(),
      oscuro: oscuro,
      escala: 2.0,
      interaccion: _abrirEliminarCuenta,
      // Es el diálogo más alto de Configuración: texto de tres líneas, label y
      // campo de confirmación. Por eso el `AlertDialog` es `scrollable`.
      verificaciones: (_) {
        expect(find.text('¿Eliminar tu cuenta?'), findsOneWidget);
        // Sin esto el caso podría quedar verde por vacío: si el campo de
        // confirmación desapareciera, no habría excepción pero tampoco
        // estaríamos tensando el diálogo completo.
        expect(find.byType(TextField), findsOneWidget);
      },
    );
  }
}
