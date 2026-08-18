import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap({required int level, required ValueChanged<int> onChanged}) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: MoodDialSelector(selectedLevel: level, onChanged: onChanged),
        ),
      ),
    );
  }

  group('MoodDialSelector', () {
    testWidgets('la flecha derecha (mejorar) emite el nivel siguiente', (
      tester,
    ) async {
      int? changed;
      await tester.pumpWidget(
        wrap(level: EstadosAnimoConst.regular, onChanged: (l) => changed = l),
      );

      await tester.tap(find.widgetWithIcon(IconButton, Icons.chevron_right));
      await tester.pumpAndSettle();

      // Orden peor→mejor: regular → bien.
      expect(changed, EstadosAnimoConst.bien);
    });

    testWidgets('la flecha izquierda (empeorar) emite el nivel anterior', (
      tester,
    ) async {
      int? changed;
      await tester.pumpWidget(
        wrap(level: EstadosAnimoConst.regular, onChanged: (l) => changed = l),
      );

      await tester.tap(find.widgetWithIcon(IconButton, Icons.chevron_left));
      await tester.pumpAndSettle();

      // Orden peor→mejor: regular → mal.
      expect(changed, EstadosAnimoConst.mal);
    });

    testWidgets('en el mejor nivel la flecha derecha queda deshabilitada', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(level: EstadosAnimoConst.muyBien, onChanged: (_) {}),
      );
      await tester.pumpAndSettle();

      final derecha = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.chevron_right),
      );
      expect(derecha.onPressed, isNull);
    });

    testWidgets('en el peor nivel la flecha izquierda queda deshabilitada', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(level: EstadosAnimoConst.muyMal, onChanged: (_) {}),
      );
      await tester.pumpAndSettle();

      final izquierda = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.chevron_left),
      );
      expect(izquierda.onPressed, isNull);
    });

    testWidgets('muestra la etiqueta del nivel actual', (tester) async {
      await tester.pumpWidget(
        wrap(level: EstadosAnimoConst.regular, onChanged: (_) {}),
      );
      await tester.pumpAndSettle();

      expect(find.text('Regular'), findsOneWidget);
    });
  });
}
