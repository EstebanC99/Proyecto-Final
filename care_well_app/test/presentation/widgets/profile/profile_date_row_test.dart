import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProfileDateRow', () {
    /// Fecha fija de referencia: el selector abre en marzo de 1985, así que
    /// los días que tocan los tests no dependen de la fecha de hoy.
    final fecha = DateTime(1985, 3, 15);

    Widget buildRow({Future<void> Function(DateTime)? onSave}) {
      return MaterialApp(
        home: Scaffold(
          body: ProfileDateRow(
            icon: Icons.cake_outlined,
            label: 'Fecha de nacimiento',
            value: fecha,
            onSave: onSave,
          ),
        ),
      );
    }

    testWidgets('muestra el rótulo y la fecha formateada', (tester) async {
      await tester.pumpWidget(buildRow());

      expect(find.text('Fecha de nacimiento'), findsOneWidget);
      expect(find.text('15/03/1985'), findsOneWidget);
    });

    testWidgets('el lápiz abre el selector de fecha', (tester) async {
      await tester.pumpWidget(buildRow());

      await tester.tap(find.byTooltip('Editar Fecha de nacimiento'));
      await tester.pumpAndSettle();

      expect(find.byType(DatePickerDialog), findsOneWidget);
    });

    testWidgets('confirmar una fecha distinta invoca onSave con el valor '
        'elegido', (tester) async {
      DateTime? guardada;
      await tester.pumpWidget(buildRow(onSave: (v) async => guardada = v));

      await tester.tap(find.byTooltip('Editar Fecha de nacimiento'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('20'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(guardada, isNotNull);
      expect(guardada!.year, 1985);
      expect(guardada!.month, 3);
      expect(guardada!.day, 20);
    });

    testWidgets('elegir la misma fecha no persiste nada', (tester) async {
      var llamadas = 0;
      await tester.pumpWidget(buildRow(onSave: (_) async => llamadas++));

      await tester.tap(find.byTooltip('Editar Fecha de nacimiento'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(llamadas, 0);
    });

    testWidgets('si el guardado falla muestra el error en la fila', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildRow(onSave: (_) async => throw Exception('sin conexión')),
      );

      await tester.tap(find.byTooltip('Editar Fecha de nacimiento'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('20'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.text('sin conexión'), findsOneWidget);
    });
  });
}
