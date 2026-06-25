import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/screens/screens.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../_fakes/fake_notification_scheduler.dart';
import '../../../_fakes/test_fixtures.dart';

// ─── Fixtures ─────────────────────────────────────────────────────────────────

final _personaAlicia = Persona(id: 2, nombre: 'Alicia', apellido: 'Rodríguez');

final _personaMaria = Persona(id: 1, nombre: 'María', apellido: 'García');

final _usuarioDemoMaria = Usuario(
  id: 101,
  persona: _personaMaria,
  contrasena: 'hash123',
  estado: estadoUsuarioActivo,
);

EventoAgenda _eventoFuturo() => EventoAgenda(
  id: 701,
  persona: _personaAlicia,
  creadoPor: _usuarioDemoMaria,
  titulo: 'Consulta cardiológica',
  tipo: tipoEventoAgendaCitaMedica,
  fechaHoraInicio: DateTime(2099, 12, 31, 10, 0),
);

EventoAgenda _eventoVencido() => EventoAgenda(
  id: 704,
  persona: _personaAlicia,
  creadoPor: _usuarioDemoMaria,
  titulo: 'Control de glucemia',
  tipo: tipoEventoAgendaControl,
  fechaHoraInicio: DateTime(2000, 1, 1, 9, 0),
);

// ─── Helper ───────────────────────────────────────────────────────────────────

Widget _wrap({
  List<EventoAgenda>? eventos,
  bool puedeGestionar = true,
  Persona? persona,
}) {
  final personaEfectiva = persona ?? _personaAlicia;
  return ProviderScope(
    overrides: [
      agendaPersonaContextProvider.overrideWith((ref) async => personaEfectiva),
      agendaEventosProvider.overrideWith((ref) async => eventos ?? []),
      puedeGestionarAgendaProvider.overrideWith((ref) async => puedeGestionar),
      recordatoriosByEventoProvider.overrideWith((ref, eventoId) async => []),
      notificationSchedulerProvider.overrideWithValue(
        FakeNotificationScheduler(),
      ),
      // ContextSelector necesita estos providers.
      careTeamContextPersonaProvider.overrideWith(
        (ref) async => personaEfectiva,
      ),
      personasSeleccionablesProvider.overrideWith(
        (ref) async => [
          PersonaContextOption(
            persona: _personaMaria,
            rol: PersonaContextRol.propio,
          ),
          PersonaContextOption(
            persona: _personaAlicia,
            rol: PersonaContextRol.responsable,
          ),
        ],
      ),
    ],
    child: const MaterialApp(home: AgendaScreen()),
  );
}

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('AgendaScreen', () {
    testWidgets('smoke: renderiza sin errores', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(AgendaScreen), findsOneWidget);
    });

    testWidgets('muestra estado vacío cuando no hay eventos', (tester) async {
      await tester.pumpWidget(_wrap(eventos: []));
      await tester.pump();

      expect(find.byType(AgendaEmptyState), findsOneWidget);
    });

    testWidgets('FAB visible solo si puede gestionar', (tester) async {
      await tester.pumpWidget(_wrap(puedeGestionar: true));
      await tester.pump();

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('FAB no visible si no puede gestionar', (tester) async {
      await tester.pumpWidget(_wrap(puedeGestionar: false));
      await tester.pump();

      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('evento futuro se muestra con opacidad normal', (tester) async {
      await tester.pumpWidget(_wrap(eventos: [_eventoFuturo()]));
      await tester.pump();

      expect(find.byType(EventCard), findsOneWidget);
    });

    testWidgets('evento vencido muestra ícono lock', (tester) async {
      await tester.pumpWidget(_wrap(eventos: [_eventoVencido()]));
      await tester.pump();

      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('muestra ContextSelector con nombre de persona', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.byType(ContextSelector), findsOneWidget);
      expect(find.textContaining('Alicia Rodríguez'), findsOneWidget);
    });

    testWidgets('sin persona de contexto muestra mensaje apropiado', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            agendaPersonaContextProvider.overrideWith((ref) async => null),
            agendaEventosProvider.overrideWith((ref) async => []),
            puedeGestionarAgendaProvider.overrideWith((ref) async => false),
            recordatoriosByEventoProvider.overrideWith(
              (ref, eventoId) async => [],
            ),
            notificationSchedulerProvider.overrideWithValue(
              FakeNotificationScheduler(),
            ),
          ],
          child: const MaterialApp(home: AgendaScreen()),
        ),
      );
      await tester.pump();

      expect(find.textContaining('persona a cargo'), findsOneWidget);
    });
  });
}
