import 'package:care_well_app/presentation/widgets/shared/step_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(
    body: Padding(padding: const EdgeInsets.all(16), child: child),
  ),
);

void main() {
  group('StepProgressBar', () {
    testWidgets('muestra "Paso 1 de 2" en el paso 1', (tester) async {
      await tester.pumpWidget(
        _wrap(const StepProgressBar(currentStep: 1, totalSteps: 2)),
      );
      expect(find.text('Paso 1 de 2'), findsOneWidget);
    });

    testWidgets('muestra "Paso 2 de 2" en el paso 2', (tester) async {
      await tester.pumpWidget(
        _wrap(const StepProgressBar(currentStep: 2, totalSteps: 2)),
      );
      expect(find.text('Paso 2 de 2'), findsOneWidget);
    });

    testWidgets('monta sin errores con totalSteps = 3', (tester) async {
      await tester.pumpWidget(
        _wrap(const StepProgressBar(currentStep: 2, totalSteps: 3)),
      );
      expect(find.text('Paso 2 de 3'), findsOneWidget);
    });

    testWidgets('monta sin errores con currentStep = totalSteps', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const StepProgressBar(currentStep: 1, totalSteps: 1)),
      );
      expect(find.text('Paso 1 de 1'), findsOneWidget);
    });
  });
}
