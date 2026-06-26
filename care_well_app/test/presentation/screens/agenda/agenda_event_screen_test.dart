import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../_fakes/fake_notification_scheduler.dart';
import '../../../_fakes/test_fixtures.dart';

// ─── Fixtures ─────────────────────────────────────────────────────────────────

final _personaAlicia = Persona(
  id: 2,
  nombre: 'Alicia',
  apellido: 'Rodríguez',
  documento: '5234100',
  fechaNacimiento: DateTime(1943, 7, 22),
);

final _personaMaria = Persona(
  id: 1,
  nombre: 'María',
  apellido: 'García',
  documento: '28000001',
  fechaNacimiento: DateTime(1990, 1, 1),
);

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
  id: 702,
  persona: _personaAlicia,
  creadoPor: _usuarioDemoMaria,
  titulo: 'Control de glucemia',
  tipo: tipoEventoAgendaControl,
  fechaHoraInicio: DateTime(2000, 1, 1, 9, 0),
);

// ─── Helpers ──────────────────────────────────────────────────────────────────

Widget _wrapAlta() {
  return ProviderScope(
    overrides: [
      authStateProvider.overrideWith(
        (ref) =>
            AuthNotifier(ref.watch(authRepositoryProvider))
              ..state = AsyncValue.data(_usuarioDemoMaria),
      ),
      agendaPersonaContextProvider.overrideWith((ref) async => _personaAlicia),
      puedeGestionarAgendaProvider.overrideWith((ref) async => true),
      notificationSchedulerProvider.overrideWithValue(
        FakeNotificationScheduler(),
      ),
    ],
    child: const MaterialApp(home: AgendaEventScreen()),
  );
}

Widget _wrapEdicion(EventoAgenda evento) {
  return ProviderScope(
    overrides: [
      authStateProvider.overrideWith(
        (ref) =>
            AuthNotifier(ref.watch(authRepositoryProvider))
              ..state = AsyncValue.data(_usuarioDemoMaria),
      ),
      agendaPersonaContextProvider.overrideWith((ref) async => _personaAlicia),
      agendaEventoByIdProvider(evento.id).overrideWith((ref) async => evento),
      recordatoriosByEventoProvider(evento.id).overrideWith((ref) async => []),
      puedeGestionarAgendaProvider.overrideWith((ref) async => true),
      notificationSchedulerProvider.overrideWithValue(
        FakeNotificationScheduler(),
      ),
    ],
    child: MaterialApp(home: AgendaEventScreen(eventId: evento.id)),
  );
}

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('AgendaEventScreen — modo alta', () {
    testWidgets('smoke: monta sin errores', (tester) async {
      await tester.pumpWidget(_wrapAlta());
      expect(find.byType(AgendaEventScreen), findsOneWidget);
    });

    testWidgets('botón crear deshabilitado cuando descripción está vacía', (
      tester,
    ) async {
      await tester.pumpWidget(_wrapAlta());
      await tester.pump();

      final botonFinder = find.text('Crear evento');
      expect(botonFinder, findsOneWidget);

      // Pulsar el botón sin ningún dato — debe mostrar error de validación.
      await tester.tap(botonFinder);
      await tester.pump();

      // Debe aparecer al menos un mensaje de error de validación.
      expect(find.text('La descripción es obligatoria.'), findsOneWidget);
    });

    testWidgets('título del AppBar es "Nuevo evento"', (tester) async {
      await tester.pumpWidget(_wrapAlta());
      await tester.pump();

      expect(find.text('Nuevo evento'), findsOneWidget);
    });
  });

  group('AgendaEventScreen — modo readonly (evento vencido)', () {
    testWidgets('muestra banner de evento vencido', (tester) async {
      await tester.pumpWidget(_wrapEdicion(_eventoVencido()));
      // Espera la inicialización async del formulario
      await tester.pumpAndSettle();

      expect(
        find.text('Este evento ya ocurrió y no puede modificarse.'),
        findsOneWidget,
      );
    });

    testWidgets('no muestra botón eliminar en modo readonly', (tester) async {
      await tester.pumpWidget(_wrapEdicion(_eventoVencido()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });
  });

  group('AgendaEventScreen — modo edición (evento futuro)', () {
    testWidgets('muestra botón eliminar para evento futuro con permiso', (
      tester,
    ) async {
      await tester.pumpWidget(_wrapEdicion(_eventoFuturo()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('muestra botón "Guardar cambios"', (tester) async {
      await tester.pumpWidget(_wrapEdicion(_eventoFuturo()));
      await tester.pumpAndSettle();

      expect(find.text('Guardar cambios'), findsOneWidget);
    });
  });
}
