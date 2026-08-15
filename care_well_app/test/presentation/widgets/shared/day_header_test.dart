import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final _hoy = DateTime(2026, 8, 12); // miércoles

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

Widget _header(DateTime dia, {int cantidadEventos = 2}) =>
    _wrap(DayHeader(dia: dia, cantidadEventos: cantidadEventos, hoy: _hoy));

void main() {
  group('DayHeader', () {
    testWidgets('rotula el día actual como HOY', (tester) async {
      await tester.pumpWidget(_header(_hoy));

      expect(find.text('HOY'), findsOneWidget);
      expect(find.textContaining('miércoles 12 de agosto'), findsOneWidget);
    });

    testWidgets('rotula el día siguiente como MAÑANA', (tester) async {
      await tester.pumpWidget(_header(DateTime(2026, 8, 13)));

      expect(find.text('MAÑANA'), findsOneWidget);
      expect(find.textContaining('jueves 13 de agosto'), findsOneWidget);
    });

    testWidgets('rotula el día anterior como AYER', (tester) async {
      await tester.pumpWidget(_header(DateTime(2026, 8, 11)));

      expect(find.text('AYER'), findsOneWidget);
    });

    testWidgets('para otros días usa el día de la semana', (tester) async {
      await tester.pumpWidget(_header(DateTime(2026, 8, 15)));

      expect(find.text('SÁBADO'), findsOneWidget);
      expect(find.textContaining('sábado 15 de agosto'), findsOneWidget);
    });

    testWidgets('singulariza la cantidad de eventos', (tester) async {
      await tester.pumpWidget(_header(_hoy, cantidadEventos: 1));

      expect(find.textContaining('1 evento'), findsOneWidget);
      expect(find.textContaining('1 eventos'), findsNothing);
    });

    testWidgets('muestra cero eventos en plural', (tester) async {
      await tester.pumpWidget(_header(_hoy, cantidadEventos: 0));

      expect(find.textContaining('0 eventos'), findsOneWidget);
    });
  });
}
