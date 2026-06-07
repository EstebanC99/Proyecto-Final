import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('AppTextField', () {
    testWidgets('renderiza el label correctamente', (tester) async {
      await tester.pumpWidget(_wrap(const AppTextField(label: 'Nombre')));

      expect(find.text('Nombre'), findsOneWidget);
    });

    testWidgets('errorText no nulo aparece en pantalla', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppTextField(label: 'Email', errorText: 'Campo inválido')),
      );

      expect(find.text('Campo inválido'), findsOneWidget);
    });

    testWidgets('enabled:false deshabilita el TextField', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppTextField(label: 'Deshabilitado', enabled: false)),
      );

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.enabled, isFalse);
    });
  });
}
