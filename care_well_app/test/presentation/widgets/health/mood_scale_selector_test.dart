import 'package:care_well_app/config/theme/app_theme.dart';
import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap({
    int? selectedLevel,
    ValueChanged<int>? onChanged,
    bool enabled = true,
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
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: MoodScaleSelector(
                selectedLevel: selectedLevel,
                onChanged: onChanged ?? (_) {},
                enabled: enabled,
              ),
            ),
          ),
        ),
      ),
    );
  }

  group('MoodScaleSelector', () {
    testWidgets('dibuja los cinco niveles de peor a mejor', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      for (final nivel in moodLevels) {
        expect(find.text(nivel.label), findsOneWidget);
      }

      // El orden de la fila es el de la escala: "Muy mal" a la izquierda.
      final peor = tester.getCenter(find.text('Muy mal'));
      final mejor = tester.getCenter(find.text('Muy bien'));
      expect(peor.dx, lessThan(mejor.dx));
    });

    testWidgets('tocar un nivel emite su id', (tester) async {
      int? elegido;
      await tester.pumpWidget(wrap(onChanged: (l) => elegido = l));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Bien'));
      await tester.pumpAndSettle();

      expect(elegido, EstadosAnimoConst.bien);
    });

    testWidgets('sin selección ningún nivel queda marcado', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      for (final nivel in moodLevels) {
        expect(
          tester.getSemantics(find.bySemanticsLabel(nivel.label)),
          isSemantics(isButton: true, isSelected: false),
        );
      }

      handle.dispose();
    });

    testWidgets('el nivel elegido se anuncia como seleccionado', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(wrap(selectedLevel: EstadosAnimoConst.mal));
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.bySemanticsLabel('Mal')),
        isSemantics(isButton: true, isSelected: true),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Bien')),
        isSemantics(isButton: true, isSelected: false),
      );

      handle.dispose();
    });

    testWidgets('con enabled false no emite selección', (tester) async {
      int? elegido;
      await tester.pumpWidget(
        wrap(enabled: false, onChanged: (l) => elegido = l),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Regular'));
      await tester.pumpAndSettle();

      expect(elegido, isNull);
    });

    testWidgets('seleccionar no cambia el tamaño de los tiles', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();
      final sinSeleccion = tester.getSize(find.text('Regular'));
      final altoFila = tester.getSize(find.byType(IntrinsicHeight));

      await tester.pumpWidget(wrap(selectedLevel: EstadosAnimoConst.regular));
      await tester.pumpAndSettle();

      // El borde está siempre (transparente sin selección) y el emoji crece
      // con `AnimatedScale`, que no ocupa lugar: nada se mueve al elegir.
      expect(tester.getSize(find.text('Regular')), sinSeleccion);
      expect(tester.getSize(find.byType(IntrinsicHeight)), altoFila);
    });

    for (final (nombre, themeMode) in [
      ('claro', ThemeMode.light),
      ('oscuro', ThemeMode.dark),
    ]) {
      testWidgets('sin overflow en tema $nombre con textScaler 1.6', (
        tester,
      ) async {
        // Cinco tiles en 360dp dan ~59dp cada uno: "Muy bien" a 16.8sp no entra
        // en una línea y tiene que envolver, con la altura mandada por el
        // contenido.
        tester.view.physicalSize = const Size(360 * 3, 640 * 3);
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          wrap(
            selectedLevel: EstadosAnimoConst.muyBien,
            textScaler: const TextScaler.linear(1.6),
            themeMode: themeMode,
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        for (final nivel in moodLevels) {
          expect(find.text(nivel.label), findsOneWidget);
        }
      });
    }

    testWidgets('los cinco tiles comparten alto', (tester) async {
      tester.view.physicalSize = const Size(360 * 3, 640 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(wrap(textScaler: const TextScaler.linear(1.6)));
      await tester.pumpAndSettle();

      final tarjetas = find.byType(AnimatedContainer).evaluate().toList();
      expect(tarjetas.length, moodLevels.length);

      final altos = tarjetas
          .map((e) => (e.renderObject! as RenderBox).size.height)
          .toSet();
      expect(altos.length, 1, reason: 'las cinco tarjetas deben medir igual');
    });
  });
}
