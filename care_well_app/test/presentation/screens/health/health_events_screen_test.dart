import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/screens/screens.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
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

// La pantalla arranca en la semana y el día de hoy: las fixtures se anclan al
// inicio del día actual para que nunca sean futuras (se filtran).
final _hoy = DateTime.now();
final _inicioDeHoy = DateTime(_hoy.year, _hoy.month, _hoy.day);
final _lunesDeEstaSemana = _inicioDeHoy.subtract(
  Duration(days: _inicioDeHoy.weekday - 1),
);

final _evento = EventoSalud(
  id: 1101,
  persona: refPersonaAlicia,
  tipo: tipoEventoSaludCitaMedica,
  fechaHora: _inicioDeHoy,
  descripcion: 'Control cardiológico',
);

/// Evento del lunes de esta semana (distinto de hoy salvo que hoy sea lunes).
final _eventoDelLunes = EventoSalud(
  id: 1102,
  persona: refPersonaAlicia,
  tipo: tipoEventoSaludVacuna,
  fechaHora: _lunesDeEstaSemana,
  descripcion: 'Vacuna antigripal',
);

final _eventoAnterior = EventoSalud(
  id: 1103,
  persona: refPersonaAlicia,
  tipo: tipoEventoSaludCitaMedica,
  fechaHora: _inicioDeHoy.subtract(const Duration(days: 12)),
  descripcion: 'Control de presión',
);

Widget _wrap({
  List<EventoSalud>? eventos,
  EventoSalud? anterior,
  bool puedeRegistrar = true,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: [
      eventosSaludDeSemanaProvider.overrideWith(
        (ref) async => eventos ?? [_evento],
      ),
      eventoSaludAnteriorProvider.overrideWith((ref) async => anterior),
      puedeRegistrarEventosSaludProvider.overrideWith(
        (ref) async => puedeRegistrar,
      ),
      personaVisualizacionSeleccionadaProvider.overrideWith(
        (ref) async => _personaAlicia,
      ),
      // El banner del ContextSelector renderiza un PersonaAvatar; se evita que
      // golpee el repositorio real cayendo al fallback de iniciales.
      personaImagenProvider.overrideWith((ref, id) async => null),
      ...overrides,
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

    testWidgets('monta la tira de semana y el encabezado del día', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      expect(find.byType(WeekStrip), findsOneWidget);
      expect(find.byType(DayHeader), findsOneWidget);
      expect(find.text('HOY'), findsOneWidget);
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

    testWidgets('la semana sin eventos muestra el estado vacío completo', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(eventos: []));
      await tester.pump();
      expect(find.text('Sin eventos en esta semana.'), findsOneWidget);
    });

    testWidgets('no navega a semanas futuras: la flecha está deshabilitada', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      final siguiente = tester.widget<Icon>(
        find.byIcon(Icons.chevron_right_rounded),
      );
      final anterior = tester.widget<Icon>(
        find.byIcon(Icons.chevron_left_rounded),
      );

      expect(siguiente.color, isNot(anterior.color));
    });

    testWidgets('al tocar otro día de la tira se filtran sus eventos', (
      tester,
    ) async {
      // Se prueba solo cuando hoy no es lunes: si lo fuera, el día del evento y
      // el día objetivo coincidirían.
      if (_inicioDeHoy == _lunesDeEstaSemana) return;

      await tester.pumpWidget(_wrap(eventos: [_evento, _eventoDelLunes]));
      await tester.pump();

      // Ambos eventos son de la misma semana, pero solo se ve el de hoy.
      expect(find.byType(HealthEventCard), findsOneWidget);
      expect(find.text('Control cardiológico'), findsOneWidget);

      await tester.tap(find.text('${_lunesDeEstaSemana.day}'));
      await tester.pump();

      expect(find.text('Vacuna antigripal'), findsOneWidget);
      expect(find.text('Control cardiológico'), findsNothing);
    });

    testWidgets('el día sin eventos muestra el mensaje breve', (tester) async {
      if (_inicioDeHoy == _lunesDeEstaSemana) return;

      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.tap(find.text('${_lunesDeEstaSemana.day}'));
      await tester.pump();

      expect(find.text('No hay eventos este día'), findsOneWidget);
      expect(find.text('Sin eventos en esta semana.'), findsNothing);
    });

    group('Anteriormente', () {
      testWidgets('muestra el último evento previo al día seleccionado', (
        tester,
      ) async {
        await tester.pumpWidget(_wrap(anterior: _eventoAnterior));
        await tester.pumpAndSettle();

        expect(find.text('ANTERIORMENTE'), findsOneWidget);
        expect(find.text('Control de presión'), findsOneWidget);
      });

      testWidgets('no se muestra cuando no hay evento previo', (tester) async {
        await tester.pumpWidget(_wrap());
        await tester.pump();

        expect(find.text('ANTERIORMENTE'), findsNothing);
      });

      testWidgets('al tocarla se navega al día de ese evento', (tester) async {
        await tester.pumpWidget(_wrap(anterior: _eventoAnterior));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Control de presión'));
        await tester.pump();

        // El encabezado deja de mostrar HOY: se saltó al día del evento previo.
        expect(find.text('HOY'), findsNothing);
      });
    });

    // La selección de día y semana vive en providers globales: sin reinicio, la
    // pantalla se reabría donde había quedado la visita anterior.
    group('reinicio de la selección', () {
      testWidgets('al abrirse vuelve al día de hoy', (tester) async {
        final haceUnMes = _inicioDeHoy.subtract(const Duration(days: 30));

        await tester.pumpWidget(
          _wrap(
            overrides: [
              diaEventosSaludSeleccionadoProvider.overrideWith(
                (ref) => haceUnMes,
              ),
              semanaEventosSaludProvider.overrideWith(
                (ref) =>
                    haceUnMes.subtract(Duration(days: haceUnMes.weekday - 1)),
              ),
            ],
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('HOY'), findsOneWidget);
      });

      testWidgets('la semana visible también vuelve a la actual', (
        tester,
      ) async {
        final haceUnMes = _inicioDeHoy.subtract(const Duration(days: 30));

        await tester.pumpWidget(
          _wrap(
            overrides: [
              semanaEventosSaludProvider.overrideWith(
                (ref) =>
                    haceUnMes.subtract(Duration(days: haceUnMes.weekday - 1)),
              ),
            ],
          ),
        );
        await tester.pumpAndSettle();

        final contexto = tester.element(find.byType(HealthEventsScreen));
        final container = ProviderScope.containerOf(contexto);
        expect(container.read(semanaEventosSaludProvider), _lunesDeEstaSemana);
      });
    });
  });
}
