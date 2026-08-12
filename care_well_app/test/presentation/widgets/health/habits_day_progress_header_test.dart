import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap({required int completados, required int total}) {
  return MaterialApp(
    home: Scaffold(
      body: HabitsDayProgressHeader(completados: completados, total: total),
    ),
  );
}

/// Cuenta los segmentos de la barra: son los únicos `Expanded` del header.
int _segmentos(WidgetTester tester) =>
    tester.widgetList(find.byType(Expanded)).length;

void main() {
  group('HabitsDayProgressHeader', () {
    testWidgets('muestra el progreso en cero', (tester) async {
      await tester.pumpWidget(_wrap(completados: 0, total: 5));
      expect(find.text('0 de 5'), findsOneWidget);
      expect(find.text('hábitos de hoy'), findsOneWidget);
    });

    testWidgets('muestra el progreso completo', (tester) async {
      await tester.pumpWidget(_wrap(completados: 5, total: 5));
      expect(find.text('5 de 5'), findsOneWidget);
    });

    testWidgets('dibuja un segmento por hábito', (tester) async {
      await tester.pumpWidget(_wrap(completados: 2, total: 5));
      expect(_segmentos(tester), 5);
    });

    testWidgets('con un solo hábito dibuja un solo segmento', (tester) async {
      await tester.pumpWidget(_wrap(completados: 0, total: 1));
      expect(_segmentos(tester), 1);
    });

    testWidgets('hasta 12 hábitos sigue segmentando', (tester) async {
      await tester.pumpWidget(_wrap(completados: 3, total: 12));
      expect(_segmentos(tester), 12);
      expect(find.byType(FractionallySizedBox), findsNothing);
    });

    testWidgets('con más de 12 hábitos pasa a barra continua', (tester) async {
      await tester.pumpWidget(_wrap(completados: 6, total: 15));
      expect(_segmentos(tester), 0);

      final barra = tester.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox),
      );
      expect(barra.widthFactor, closeTo(6 / 15, 0.0001));
    });

    testWidgets('expone el progreso en la semántica', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap(completados: 2, total: 5));

      expect(
        find.bySemanticsLabel('2 de 5 hábitos completados hoy'),
        findsOneWidget,
      );
      handle.dispose();
    });
  });
}
