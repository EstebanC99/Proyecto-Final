import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('SummaryAttentionCard', () {
    testWidgets('con los dos grupos muestra el rótulo y el divisor', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const SummaryAttentionCard(
            recomendaciones: ['Vigilá la digestión.'],
            recordatoriosHoy: ['Medicación de la noche'],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('A tener en cuenta'), findsOneWidget);
      expect(find.text('Vigilá la digestión.'), findsOneWidget);
      expect(find.text('Pendientes de hoy'), findsOneWidget);
      expect(find.text('Medicación de la noche'), findsOneWidget);
      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets('con un solo grupo no pinta el divisor', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const SummaryAttentionCard(recomendaciones: ['Vigilá la digestión.']),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Divider), findsNothing);
      expect(find.text('Pendientes de hoy'), findsNothing);
    });

    testWidgets('solo con recordatorios muestra el rótulo sin divisor', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const SummaryAttentionCard(
            recordatoriosHoy: ['Medicación de la noche'],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pendientes de hoy'), findsOneWidget);
      expect(find.byType(Divider), findsNothing);
    });
  });
}
