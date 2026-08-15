import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final _tipo = TipoEvento(id: 1, descripcion: 'Cita Médica');

/// Ocurrencia futura (editable) con la duración indicada.
OcurrenciaEventoAgenda _ocurrencia({int duracionMinutos = 60}) {
  final inicio = DateTime.now().add(const Duration(days: 2));
  return OcurrenciaEventoAgenda(
    id: 1,
    eventoAgendaId: 1,
    personaId: 12,
    titulo: 'Control clínico',
    tipo: _tipo,
    fechaHoraInicio: inicio,
    fechaHoraFin: inicio.add(Duration(minutes: duracionMinutos)),
    esRecurrente: false,
    generarEventoSalud: false,
  );
}

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('OcurrenciaCard', () {
    testWidgets('muestra el título y la hora de inicio', (tester) async {
      final ocurrencia = _ocurrencia();
      await tester.pumpWidget(_wrap(OcurrenciaCard(ocurrencia: ocurrencia)));

      final hora =
          '${ocurrencia.fechaHoraInicio.hour.toString().padLeft(2, '0')}:'
          '${ocurrencia.fechaHoraInicio.minute.toString().padLeft(2, '0')}';

      expect(find.text('Control clínico'), findsOneWidget);
      expect(find.text(hora), findsOneWidget);
    });

    group('duración', () {
      testWidgets('muestra minutos cuando dura menos de una hora', (
        tester,
      ) async {
        await tester.pumpWidget(
          _wrap(OcurrenciaCard(ocurrencia: _ocurrencia(duracionMinutos: 45))),
        );

        expect(find.text('45 min'), findsOneWidget);
      });

      testWidgets('muestra horas exactas sin minutos', (tester) async {
        await tester.pumpWidget(
          _wrap(OcurrenciaCard(ocurrencia: _ocurrencia(duracionMinutos: 120))),
        );

        expect(find.text('2 h'), findsOneWidget);
      });

      testWidgets('muestra horas y minutos combinados', (tester) async {
        await tester.pumpWidget(
          _wrap(OcurrenciaCard(ocurrencia: _ocurrencia(duracionMinutos: 90))),
        );

        expect(find.text('1 h 30 min'), findsOneWidget);
      });

      testWidgets('no muestra duración cuando es nula', (tester) async {
        await tester.pumpWidget(
          _wrap(OcurrenciaCard(ocurrencia: _ocurrencia(duracionMinutos: 0))),
        );

        expect(find.textContaining('min'), findsNothing);
        expect(find.textContaining(' h'), findsNothing);
      });
    });

    testWidgets('dispara onTap cuando es interactiva', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          OcurrenciaCard(ocurrencia: _ocurrencia(), onTap: () => tapped = true),
        ),
      );

      await tester.tap(find.text('Control clínico'));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
