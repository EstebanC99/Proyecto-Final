import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

const _habitos = [
  HabitoResumen(descripcion: 'Caminata matutina', completado: true),
  HabitoResumen(descripcion: 'Almuerzo liviano', completado: true),
  HabitoResumen(descripcion: 'Medicación de la tarde', completado: true),
  HabitoResumen(descripcion: 'Ejercicios de memoria', completado: true),
  HabitoResumen(descripcion: 'Cena', completado: false),
  HabitoResumen(descripcion: 'Lectura antes de dormir', completado: false),
];

void main() {
  group('SummaryHabitsCard', () {
    testWidgets('muestra la meta, el anillo y una pill por hábito', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const SummaryHabitsCard(
            habitos: _habitos,
            completados: 4,
            progreso: 4 / 6,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Hábitos de hoy'), findsOneWidget);
      expect(find.text('4 de 6'), findsOneWidget);
      expect(find.byType(HabitsProgressRing), findsOneWidget);
      expect(find.byType(SummaryHabitChip), findsNWidgets(6));
    });

    testWidgets('el tick solo aparece en los hábitos completados', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const SummaryHabitsCard(
            habitos: _habitos,
            completados: 4,
            progreso: 4 / 6,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check), findsNWidgets(4));
      expect(
        find.bySemanticsLabel('Caminata matutina, completado'),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Cena, pendiente'), findsOneWidget);
    });

    testWidgets(
      'con comentario pero sin lista se reduce al texto: ni anillo, ni pills, '
      'ni meta "0 de 0"',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            const SummaryHabitsCard(
              habitos: [],
              completados: 0,
              progreso: 0,
              resumen: 'Cumplió con casi toda la rutina.',
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Cumplió con casi toda la rutina.'), findsOneWidget);
        expect(find.byType(HabitsProgressRing), findsNothing);
        expect(find.byType(SummaryHabitChip), findsNothing);
        expect(find.text('0 de 0'), findsNothing);
      },
    );
  });
}
