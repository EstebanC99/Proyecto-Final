import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('SummaryEntryCard', () {
    testWidgets('renderiza sin errores (smoke)', (tester) async {
      await tester.pumpWidget(_wrap(const SummaryEntryCard()));
      await tester.pumpAndSettle();
      expect(find.byType(SummaryEntryCard), findsOneWidget);
    });

    testWidgets('muestra el título y el ícono de IA', (tester) async {
      await tester.pumpWidget(_wrap(const SummaryEntryCard()));
      await tester.pumpAndSettle();
      expect(find.text('Resumen inteligente'), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
    });
  });
}
