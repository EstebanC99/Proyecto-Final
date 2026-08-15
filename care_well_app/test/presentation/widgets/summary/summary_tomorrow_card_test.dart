import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('SummaryTomorrowCard', () {
    testWidgets('arranca colapsada: solo se ve el encabezado', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const SummaryTomorrowCard(
            recordatorios: ['Turno con el veterinario'],
            habitos: [
              HabitoResumen(descripcion: 'Paseo matutino', completado: false),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mañana'), findsOneWidget);
      expect(find.text('1 hábito'), findsOneWidget);
      expect(find.text('Turno con el veterinario'), findsNothing);
    });

    testWidgets('al tocar el encabezado despliega el contenido', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const SummaryTomorrowCard(
            recordatorios: ['Turno con el veterinario'],
            habitos: [
              HabitoResumen(descripcion: 'Paseo matutino', completado: false),
              HabitoResumen(descripcion: 'Cena', completado: false),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Mañana'));
      await tester.pumpAndSettle();

      expect(find.text('Turno con el veterinario'), findsOneWidget);
      expect(find.text('2 hábitos'), findsOneWidget);

      // Y vuelve a colapsar.
      await tester.tap(find.text('Mañana'));
      await tester.pumpAndSettle();
      expect(find.text('Turno con el veterinario'), findsNothing);
    });

    testWidgets('sin recordatorios muestra la línea neutra al expandir', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const SummaryTomorrowCard(
            habitos: [
              HabitoResumen(descripcion: 'Paseo matutino', completado: false),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Mañana'));
      await tester.pumpAndSettle();

      expect(
        find.text('Sin turnos ni recordatorios agendados.'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('Paseo matutino, pendiente'),
        findsOneWidget,
      );
    });

    testWidgets('sin hábitos no muestra la meta del encabezado', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const SummaryTomorrowCard(
            recordatorios: ['Turno con la nutricionista'],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mañana'), findsOneWidget);
      expect(find.textContaining('hábito'), findsNothing);
    });

    testWidgets('el encabezado se anuncia como botón con estado expandible', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _wrap(const SummaryTomorrowCard(recordatorios: ['Turno'])),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.bySemanticsLabel('Mañana')),
        isSemantics(
          isButton: true,
          hasExpandedState: true,
          isExpanded: false,
          hasTapAction: true,
        ),
      );

      await tester.tap(find.text('Mañana'));
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.bySemanticsLabel('Mañana')),
        isSemantics(hasExpandedState: true, isExpanded: true),
      );

      handle.dispose();
    });
  });
}
