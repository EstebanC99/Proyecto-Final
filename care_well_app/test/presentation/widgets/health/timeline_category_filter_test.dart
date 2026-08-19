import 'package:care_well_app/config/theme/app_theme.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap({
    String? seleccionada,
    ValueChanged<String?>? onChanged,
    TextScaler textScaler = TextScaler.noScaling,
    ThemeMode themeMode = ThemeMode.light,
  }) {
    return MaterialApp(
      themeMode: themeMode,
      theme: AppTheme().light,
      darkTheme: AppTheme().dark,
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: textScaler),
          child: Scaffold(
            // `mainAxisSize.min` para que el filtro tome su alto intrínseco y
            // se pueda medir si crece con la escala.
            body: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TimelineCategoryFilter(
                  seleccionada: seleccionada,
                  onChanged: onChanged ?? (_) {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Fija el ancho del dispositivo en el de un teléfono común.
  void usarPantallaDe360(WidgetTester tester) {
    tester.view.physicalSize = const Size(360 * 3, 640 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  group('TimelineCategoryFilter', () {
    testWidgets('los cuatro chips existen en un ancho de teléfono', (
      tester,
    ) async {
      // Antes la fila era un `ListView` perezoso con los rótulos largos de las
      // filas ("Evento de salud", "Estado de ánimo"): el último chip quedaba
      // tan afuera que ni se construía, y el filtro más usado era inalcanzable
      // detrás de un scroll que nada anuncia.
      //
      // No se afirma nada sobre píxeles: la fuente de `flutter_test` da un em
      // por glifo, así que cualquier medición de ancho de texto sobrevalúa lo
      // que ocupa Roboto y no diría nada de la app real. Lo que sí es
      // font-independiente —y es el fondo del problema— es que las cuatro
      // opciones estén en el árbol y se puedan tocar.
      usarPantallaDe360(tester);
      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      for (final texto in ['Todo', 'Hábitos', 'Eventos', 'Ánimo']) {
        expect(
          find.text(texto),
          findsOneWidget,
          reason: 'falta el chip $texto',
        );
      }
    });

    test('la fila de rótulos cortos ocupa bastante menos que la larga', () {
      // La otra mitad del arreglo. Lo que decide si los cuatro chips entran es
      // el total de la fila, no cada rótulo por separado: "Hábitos" es más
      // largo que "Hábito", pero "Eventos" y "Ánimo" ahorran mucho más.
      int total(String Function(String) rotulo) => TimelineCategorias.todas
          .map((c) => rotulo(c).length)
          .reduce((a, b) => a + b);

      expect(
        total(categoriaEventoLabelCorto),
        lessThan(total(categoriaEventoLabel) * 0.7),
      );
      expect(categoriaEventoLabelCorto(TimelineCategorias.evento), 'Eventos');
      expect(categoriaEventoLabelCorto(TimelineCategorias.animo), 'Ánimo');
      // Una categoría nueva sin rótulo corto cae al valor crudo, como la larga.
      expect(categoriaEventoLabelCorto('Otra'), 'Otra');
    });

    testWidgets('la fila crece con la escala tipográfica', (tester) async {
      // Sin alto fijo: si alguien vuelve a clavarlo, el texto se recorta por
      // abajo sin lanzar ninguna excepción y este test es el que avisa.
      usarPantallaDe360(tester);

      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();
      final normal = tester.getSize(find.byType(TimelineCategoryFilter)).height;

      await tester.pumpWidget(wrap(textScaler: const TextScaler.linear(1.6)));
      await tester.pumpAndSettle();
      final grande = tester.getSize(find.byType(TimelineCategoryFilter)).height;

      expect(grande, greaterThan(normal));
    });

    testWidgets('tocar un chip emite su categoría', (tester) async {
      String? elegida;
      await tester.pumpWidget(wrap(onChanged: (c) => elegida = c));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Eventos'));
      await tester.pumpAndSettle();

      expect(elegida, TimelineCategorias.evento);
    });

    testWidgets('"Todo" emite null', (tester) async {
      String? elegida = TimelineCategorias.habito;
      await tester.pumpWidget(
        wrap(
          seleccionada: TimelineCategorias.habito,
          onChanged: (c) => elegida = c,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Todo'));
      await tester.pumpAndSettle();

      expect(elegida, isNull);
    });

    testWidgets('el chip activo se anuncia como seleccionado', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(wrap(seleccionada: TimelineCategorias.animo));
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.bySemanticsLabel('Ánimo')),
        isSemantics(isButton: true, isSelected: true),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Todo')),
        isSemantics(isButton: true, isSelected: false),
      );

      handle.dispose();
    });

    for (final (nombre, themeMode) in [
      ('claro', ThemeMode.light),
      ('oscuro', ThemeMode.dark),
    ]) {
      testWidgets('sin overflow en tema $nombre con textScaler 1.6', (
        tester,
      ) async {
        usarPantallaDe360(tester);

        await tester.pumpWidget(
          wrap(
            seleccionada: TimelineCategorias.habito,
            textScaler: const TextScaler.linear(1.6),
            themeMode: themeMode,
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        for (final texto in ['Todo', 'Hábitos', 'Eventos', 'Ánimo']) {
          expect(find.text(texto), findsOneWidget);
        }
      });
    }
  });
}
