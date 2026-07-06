import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/screens/screens.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../../_fakes/test_fixtures.dart';

final _personaAlicia = Persona(
  id: 2,
  nombre: 'Alicia',
  apellido: 'Rodríguez',
  documento: '5234100',
  fechaNacimiento: DateTime(1943, 7, 22),
);

// La lista agrupa por día y expande hoy/mañana por defecto: se usa la fecha de
// hoy para que la card del evento quede visible sin interacción. Se fija al
// inicio del día para que nunca sea futura (la pantalla filtra eventos futuros).
final _hoy = DateTime.now();

final _evento = EventoSalud(
  id: 1101,
  persona: refPersonaAlicia,
  tipo: tipoEventoSaludCitaMedica,
  fechaHora: DateTime(_hoy.year, _hoy.month, _hoy.day),
  descripcion: 'Control cardiológico',
);

Widget _wrap({List<EventoSalud>? eventos, bool puedeRegistrar = true}) {
  return ProviderScope(
    overrides: [
      eventosSaludDelMesProvider.overrideWith(
        (ref) async => eventos ?? [_evento],
      ),
      puedeRegistrarEventosSaludProvider.overrideWith(
        (ref) async => puedeRegistrar,
      ),
      healthPersonaContextProvider.overrideWith((ref) async => _personaAlicia),
    ],
    child: const MaterialApp(home: HealthEventsScreen()),
  );
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  group('HealthEventsScreen', () {
    testWidgets('smoke: renderiza sin errores', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(HealthEventsScreen), findsOneWidget);
    });

    testWidgets('muestra cards de eventos', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(HealthEventCard), findsOneWidget);
    });

    testWidgets('FAB visible si puede registrar', (tester) async {
      await tester.pumpWidget(_wrap(puedeRegistrar: true));
      await tester.pump();
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('FAB NO visible si no puede registrar', (tester) async {
      await tester.pumpWidget(_wrap(puedeRegistrar: false));
      await tester.pump();
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('muestra estado vacío cuando no hay eventos', (tester) async {
      await tester.pumpWidget(_wrap(eventos: []));
      await tester.pump();
      expect(find.text('Sin eventos en este mes.'), findsOneWidget);
    });

    testWidgets('muestra la lista mensual (única vista)', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(HealthEventsMonthList), findsOneWidget);
    });

    testWidgets('no expone toggle de línea de tiempo', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byTooltip('Ver como línea de tiempo'), findsNothing);
    });
  });
}
