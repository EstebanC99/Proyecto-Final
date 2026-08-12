import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('SummaryHealthTimelineCard', () {
    testWidgets('pinta hora, descripción y hábito asociado', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const SummaryHealthTimelineCard(
            eventos: [
              EventoSaludResumen(
                descripcion: 'Comió algo en la vereda',
                hora: '08:45',
                actividadHabitoAsociado: 'Durante el paseo matutino',
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Salud'), findsOneWidget);
      expect(find.text('1 registro'), findsOneWidget);
      expect(find.text('08:45'), findsOneWidget);
      expect(find.text('Comió algo en la vereda'), findsOneWidget);
      expect(find.text('Durante el paseo matutino'), findsOneWidget);
    });

    testWidgets('un evento sin hora no rompe la grilla', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const SummaryHealthTimelineCard(
            eventos: [
              EventoSaludResumen(descripcion: 'Con hora', hora: '10:00'),
              EventoSaludResumen(descripcion: 'Sin hora'),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('2 registros'), findsOneWidget);
      expect(find.text('Sin hora'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('un evento sin hábito asociado solo muestra la descripción', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const SummaryHealthTimelineCard(
            eventos: [EventoSaludResumen(descripcion: 'Salida', hora: '12:15')],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Salida'), findsOneWidget);
      expect(find.byType(Text), findsNWidgets(4)); // título, meta, hora, desc.
    });
  });
}
