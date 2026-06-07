import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('PrimaryButton', () {
    testWidgets('renderiza el label correctamente', (tester) async {
      await tester.pumpWidget(
        _wrap(const PrimaryButton(label: 'Ingresar', onPressed: null)),
      );

      expect(find.text('Ingresar'), findsOneWidget);
    });

    testWidgets('isLoading muestra spinner y deshabilita el boton', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const PrimaryButton(label: 'Ingresar', isLoading: true)),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Ingresar'), findsNothing);

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('onPressed null deshabilita el boton', (tester) async {
      await tester.pumpWidget(
        _wrap(const PrimaryButton(label: 'Ingresar', onPressed: null)),
      );

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });
  });
}
