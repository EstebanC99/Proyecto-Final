import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProfileDataRow', () {
    Widget buildRow({
      String value = 'test@example.com',
      bool editable = false,
      Future<void> Function(String)? onSave,
      String? Function(String?)? validator,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: ProfileDataRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: value,
            editable: editable,
            onSave: onSave,
            validator: validator,
          ),
        ),
      );
    }

    testWidgets('modo lectura muestra label y valor', (tester) async {
      await tester.pumpWidget(buildRow());

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('modo lectura sin editable no muestra ícono lápiz', (
      tester,
    ) async {
      await tester.pumpWidget(buildRow(editable: false));

      expect(find.byIcon(Icons.edit), findsNothing);
    });

    testWidgets('modo lectura con editable muestra ícono lápiz', (
      tester,
    ) async {
      await tester.pumpWidget(buildRow(editable: true, onSave: (_) async {}));

      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('tap en lápiz activa el campo de edición', (tester) async {
      await tester.pumpWidget(buildRow(editable: true, onSave: (_) async {}));

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pump();

      // En modo edición aparece check y close.
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('tap en cancelar (close) vuelve al modo lectura', (
      tester,
    ) async {
      await tester.pumpWidget(buildRow(editable: true, onSave: (_) async {}));

      // Activar edición.
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pump();

      // Cancelar.
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      // Vuelve al modo lectura.
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.check), findsNothing);
    });

    testWidgets('tap en check llama onSave con el valor nuevo', (tester) async {
      String? valorGuardado;

      await tester.pumpWidget(
        buildRow(editable: true, onSave: (v) async => valorGuardado = v),
      );

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pump();

      // Limpiar y escribir nuevo valor.
      await tester.enterText(find.byType(TextField), 'nuevo@example.com');

      await tester.tap(find.byIcon(Icons.check));
      await tester.pump();

      expect(valorGuardado, 'nuevo@example.com');
    });

    testWidgets('validación fallida muestra error y no llama onSave', (
      tester,
    ) async {
      String? valorGuardado;

      await tester.pumpWidget(
        buildRow(
          editable: true,
          onSave: (v) async => valorGuardado = v,
          validator: (v) => (v == null || v.isEmpty) ? 'Campo requerido' : null,
        ),
      );

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pump();

      // Borrar contenido.
      await tester.enterText(find.byType(TextField), '');

      await tester.tap(find.byIcon(Icons.check));
      await tester.pump();

      // No guardó.
      expect(valorGuardado, isNull);
      // Muestra error.
      expect(find.text('Campo requerido'), findsOneWidget);
    });
  });
}
