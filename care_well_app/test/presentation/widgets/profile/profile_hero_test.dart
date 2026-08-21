import 'package:care_well_app/config/theme/app_theme.dart';
import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Persona _persona({String nombre = 'María', String apellido = 'García'}) =>
    Persona(
      id: 1,
      nombre: nombre,
      apellido: apellido,
      documento: '28000001',
      fechaNacimiento: DateTime(1985, 3, 15),
      email: 'maria@example.com',
      telefono: '+54 9 11 1234-5678',
    );

Widget _wrap(
  Widget child, {
  Brightness brightness = Brightness.light,
  TextScaler textScaler = TextScaler.noScaling,
}) {
  final tema = AppTheme();
  return MaterialApp(
    theme: brightness == Brightness.light ? tema.light : tema.dark,
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: textScaler),
        child: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    ),
  );
}

ProfileHero _hero({
  AsyncValue<RolEnSistema?> rol = const AsyncValue.data(
    RolEnSistema.responsable,
  ),
  Persona? persona,
  VoidCallback? onEditarNombre,
  VoidCallback? onVerFoto,
  VoidCallback? onCambiarFoto,
}) => ProfileHero(
  persona: persona ?? _persona(),
  rol: rol,
  imagen: null,
  onEditarNombre: onEditarNombre ?? () {},
  onVerFoto: onVerFoto ?? () {},
  onCambiarFoto: onCambiarFoto ?? () {},
);

void main() {
  group('ProfileHero', () {
    testWidgets('muestra el nombre completo', (tester) async {
      await tester.pumpWidget(_wrap(_hero()));

      expect(find.text('María García'), findsOneWidget);
    });

    testWidgets('con rol muestra el chip', (tester) async {
      await tester.pumpWidget(_wrap(_hero()));

      expect(find.text('Responsable'), findsOneWidget);
      expect(find.byKey(const Key('rol-chip-placeholder')), findsNothing);
    });

    testWidgets('sin rol no muestra chip ni reserva lugar', (tester) async {
      await tester.pumpWidget(
        _wrap(_hero(rol: const AsyncValue<RolEnSistema?>.data(null))),
      );

      expect(find.text('Responsable'), findsNothing);
      expect(find.text('Cuidador'), findsNothing);
      expect(find.byKey(const Key('rol-chip-placeholder')), findsNothing);
    });

    testWidgets('en error no muestra chip ni reserva lugar', (tester) async {
      await tester.pumpWidget(
        _wrap(
          _hero(
            rol: AsyncValue<RolEnSistema?>.error('falló', StackTrace.empty),
          ),
        ),
      );

      expect(find.byKey(const Key('rol-chip-placeholder')), findsNothing);
      expect(find.text('Responsable'), findsNothing);
    });

    // Ojo: un `FutureProvider` que falla NO queda como `AsyncError`, queda como
    // `AsyncLoading` con `hasError` en `true`. Ese estado no se puede construir
    // acá sin API interna de Riverpod, así que lo cubre el test de pantalla
    // "con el rol en error tampoco se reserva lugar", que hace fallar al
    // provider de verdad.

    testWidgets('mientras carga reserva el lugar del chip', (tester) async {
      await tester.pumpWidget(
        _wrap(_hero(rol: const AsyncValue<RolEnSistema?>.loading())),
      );

      expect(find.byKey(const Key('rol-chip-placeholder')), findsOneWidget);
    });

    testWidgets('el alto del hero no cambia al resolver el rol', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(_hero(rol: const AsyncValue<RolEnSistema?>.loading())),
      );
      final altoCargando = tester.getSize(find.byType(ProfileHero)).height;

      await tester.pumpWidget(_wrap(_hero()));
      final altoConRol = tester.getSize(find.byType(ProfileHero)).height;

      expect(altoConRol, altoCargando);
    });

    testWidgets('el alto tampoco cambia con escala tipográfica alta', (
      tester,
    ) async {
      const escala = TextScaler.linear(1.8);

      await tester.pumpWidget(
        _wrap(
          _hero(rol: const AsyncValue<RolEnSistema?>.loading()),
          textScaler: escala,
        ),
      );
      final altoCargando = tester.getSize(find.byType(ProfileHero)).height;

      await tester.pumpWidget(_wrap(_hero(), textScaler: escala));
      final altoConRol = tester.getSize(find.byType(ProfileHero)).height;

      expect(altoConRol, altoCargando);
    });

    testWidgets('el tap sobre el nombre abre la edición', (tester) async {
      var edito = false;
      await tester.pumpWidget(_wrap(_hero(onEditarNombre: () => edito = true)));

      await tester.tap(find.text('María García'));

      expect(edito, isTrue);
    });

    testWidgets(
      'la fila del nombre se anuncia como un único botón, con el nombre',
      (tester) async {
        await tester.pumpWidget(_wrap(_hero()));

        // El nombre entra en el label: es el único lugar del hero donde se
        // comunica de quién es el perfil.
        expect(
          find.bySemanticsLabel('María García. Editar nombre y apellido'),
          findsOneWidget,
        );
      },
    );

    testWidgets('el área tocable del nombre llega al mínimo de 48dp', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(_hero()));

      final alto = tester.getSize(find.byType(InkWell)).height;

      expect(alto, greaterThanOrEqualTo(48));
    });

    testWidgets('el avatar, el nombre y el chip quedan centrados en el hero', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(_hero()));

      final centroDelHero = tester.getCenter(find.byType(ProfileHero)).dx;

      // El avatar: su `Stack` mide lo que el círculo (el badge es `Positioned`
      // y no aporta tamaño), así que su centro es el centro visual de la foto.
      expect(
        tester.getCenter(find.byType(ProfileHeroAvatar)).dx,
        closeTo(centroDelHero, 1.0),
      );
      // La fila del nombre —el único `InkWell` del hero, el avatar usa
      // `GestureDetector`— y no el `Text`: el lápiz de al lado corre el texto
      // a la izquierda del centro aun con la fila perfectamente centrada.
      expect(
        tester.getCenter(find.byType(InkWell)).dx,
        closeTo(centroDelHero, 1.0),
      );
      // Ídem el chip: se mide la pastilla completa, no su texto, que el ícono
      // desplaza.
      expect(
        tester.getCenter(find.byKey(const Key('rol-chip'))).dx,
        closeTo(centroDelHero, 1.0),
      );
    });

    // Un solo caso, en tema claro: el centrado sale del mismo árbol de widgets
    // en ambos temas (sólo cambian los colores), así que repetirlo en oscuro no
    // agregaría un motivo nuevo por el que pudiera fallar.

    testWidgets('un nombre largo no desborda', (tester) async {
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _wrap(
          _hero(
            persona: _persona(
              nombre: 'Maximiliano Bartolomé',
              apellido: 'De la Fuente Etchegaray',
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('en claro el fondo es un degradado', (tester) async {
      await tester.pumpWidget(_wrap(_hero()));

      final decoracion = _decoracionDelHero(tester);

      expect(decoracion.gradient, isNotNull);
      expect(decoracion.color, isNull);
    });

    testWidgets('en oscuro el fondo es plano', (tester) async {
      await tester.pumpWidget(_wrap(_hero(), brightness: Brightness.dark));

      final decoracion = _decoracionDelHero(tester);

      expect(decoracion.gradient, isNull);
      expect(decoracion.color, isNotNull);
    });

    testWidgets('el avatar delega sus dos acciones', (tester) async {
      var cambio = false;
      await tester.pumpWidget(_wrap(_hero(onCambiarFoto: () => cambio = true)));

      await tester.tap(find.byKey(ProfileHeroAvatar.badgeKey));

      expect(cambio, isTrue);
    });
  });
}

/// Decoración del contenedor de fondo del hero.
BoxDecoration _decoracionDelHero(WidgetTester tester) {
  final container = tester.widget<Container>(
    find
        .descendant(
          of: find.byType(ProfileHero),
          matching: find.byType(Container),
        )
        .first,
  );
  return container.decoration! as BoxDecoration;
}
