import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/screens/screens.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../../_fakes/test_fixtures.dart';

final _personaAlicia = Persona(id: 2, nombre: 'Alicia', apellido: 'Rodríguez');

EventoDeSalud _evento(int id, DateTime fecha) => EventoDeSalud(
  id: id,
  persona: _personaAlicia,
  tipo: tipoEventoSaludCitaMedica,
  fecha: fecha,
  descripcion: 'Descripción $id',
);

Widget _wrap({List<EventoDeSalud>? eventos}) {
  // eventosSaludProvider ya retorna ordenado descendente; timeline los invierte.
  return ProviderScope(
    overrides: [
      eventosSaludProvider.overrideWith(
        (ref) async =>
            eventos ??
            [
              _evento(1102, DateTime(2026, 6, 1)),
              _evento(1101, DateTime(2026, 3, 1)),
            ],
      ),
      healthPersonaContextProvider.overrideWith((ref) async => _personaAlicia),
    ],
    child: const MaterialApp(home: TimelineScreen()),
  );
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  group('TimelineScreen', () {
    testWidgets('smoke: renderiza sin errores', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(TimelineScreen), findsOneWidget);
    });

    testWidgets('muestra TimelineTile por cada evento', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(TimelineTile), findsNWidgets(2));
    });

    testWidgets('muestra estado vacío cuando no hay eventos', (tester) async {
      await tester.pumpWidget(_wrap(eventos: []));
      await tester.pump();
      expect(find.textContaining('no hay eventos'), findsOneWidget);
    });

    testWidgets('último TimelineTile tiene isLast=true (sin línea)', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      // Verificamos que se renderizan exactamente 2 tiles.
      final tiles = tester.widgetList<TimelineTile>(find.byType(TimelineTile));
      final tilesLista = tiles.toList();
      expect(tilesLista.last.isLast, isTrue);
      expect(tilesLista.first.isLast, isFalse);
    });
  });
}
