import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('HabitsProgressRing', () {
    testWidgets('muestra el conteo y el label accesible', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const HabitsProgressRing(completados: 4, total: 6, progreso: 4 / 6),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('4/6'), findsOneWidget);
      expect(find.text('completos'), findsOneWidget);
      expect(
        find.bySemanticsLabel('4 de 6 hábitos completados'),
        findsOneWidget,
      );
    });

    testWidgets('renderiza el 0 % sin errores', (tester) async {
      await tester.pumpWidget(
        _wrap(const HabitsProgressRing(completados: 0, total: 6, progreso: 0)),
      );
      await tester.pumpAndSettle();

      expect(find.text('0/6'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renderiza el 100 % sin errores', (tester) async {
      await tester.pumpWidget(
        _wrap(const HabitsProgressRing(completados: 6, total: 6, progreso: 1)),
      );
      await tester.pumpAndSettle();

      expect(find.text('6/6'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('soporta total 0 sin dividir por cero', (tester) async {
      await tester.pumpWidget(
        _wrap(const HabitsProgressRing(completados: 0, total: 0, progreso: 0)),
      );
      await tester.pumpAndSettle();

      expect(find.text('0/0'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
