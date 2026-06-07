import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/screens/screens.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

final _personaAlicia = Persona(
  id: 'per_002',
  nombre: 'Alicia',
  apellido: 'Rodríguez',
);

final _evento = EventoDeSalud(
  id: 'esa_001',
  persona: _personaAlicia,
  tipo: TipoEventoSalud.citaMedica,
  fecha: DateTime(2026, 6, 2),
  descripcion: 'Control cardiológico',
);

Widget _wrap({List<EventoDeSalud>? eventos, bool puedeRegistrar = true}) {
  return ProviderScope(
    overrides: [
      eventosSaludProvider.overrideWith((ref) async => eventos ?? [_evento]),
      puedeRegistrarEventosSaludProvider.overrideWith(
        (ref) async => puedeRegistrar,
      ),
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
      expect(find.text('No hay eventos registrados aún.'), findsOneWidget);
    });
  });
}
