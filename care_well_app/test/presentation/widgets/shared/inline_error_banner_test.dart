import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('InlineErrorBanner', () {
    testWidgets('renderiza el mensaje correctamente', (tester) async {
      await tester.pumpWidget(
        _wrap(const InlineErrorBanner(message: 'Error de prueba')),
      );

      expect(find.text('Error de prueba'), findsOneWidget);
    });

    testWidgets('muestra el ícono Icons.error_outline', (tester) async {
      await tester.pumpWidget(
        _wrap(const InlineErrorBanner(message: 'Algo salió mal')),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });
}
