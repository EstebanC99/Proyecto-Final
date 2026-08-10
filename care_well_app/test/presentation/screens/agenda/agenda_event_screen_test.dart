import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/screens/agenda/agenda_event_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// ─── Fixtures ─────────────────────────────────────────────────────────────────

final _persona = Persona(
  id: 12,
  nombre: 'Alicia',
  apellido: 'Rodríguez',
  documento: '5234100',
  fechaNacimiento: DateTime(1943, 7, 22),
);

final _tipo = TipoEvento(id: 1, descripcion: 'Cita Médica');

DateTime _soloFecha(DateTime f) => DateTime(f.year, f.month, f.day);

final _hoy = _soloFecha(DateTime.now());
final _lunesDeEstaSemana = _hoy.subtract(Duration(days: _hoy.weekday - 1));

/// Lunes de una semana lejana, usada como estado inicial de la agenda para
/// comprobar que al guardar se salta a la semana del evento.
final _lunesLejano = _lunesDeEstaSemana.subtract(const Duration(days: 42));

OcurrenciaEventoAgenda _ocurrencia(DateTime inicio) => OcurrenciaEventoAgenda(
  id: 7,
  eventoAgendaId: 7,
  personaId: _persona.id,
  titulo: 'Control cardiológico',
  tipo: _tipo,
  fechaHoraInicio: inicio,
  fechaHoraFin: inicio.add(const Duration(hours: 1)),
  esRecurrente: false,
  generarEventoSalud: false,
);

// ─── Helpers ──────────────────────────────────────────────────────────────────

/// No-op con la firma de [crearEventoAgendaProvider].
Future<void> _crearNoop({
  required int personaId,
  required String titulo,
  String? descripcion,
  required int tipoEventoId,
  required DateTime fechaHoraInicio,
  required int duracionMinutos,
  required bool generarEventoSalud,
  int? minutosAnticipacionRecordatorio,
  int? frecuenciaRecurrenciaId,
  int? intervaloRecurrencia,
  DateTime? fechaFinRecurrencia,
}) async {}

/// No-op con la firma de [modificarEventoAgendaProvider].
Future<void> _modificarNoop({
  required int eventoAgendaId,
  required String titulo,
  String? descripcion,
  required int tipoEventoId,
  required DateTime fechaHoraInicio,
  required int duracionMinutos,
  required bool generarEventoSalud,
  int? minutosAnticipacionRecordatorio,
}) async {}

ProviderContainer _container({
  List<OcurrenciaEventoAgenda> ocurrencias = const [],
}) {
  final container = ProviderContainer(
    overrides: [
      agendaPersonaContextProvider.overrideWith((ref) async => _persona),
      personaVisualizacionSeleccionadaProvider.overrideWith(
        (ref) async => _persona,
      ),
      tiposEventoAgendablesProvider.overrideWith((ref) async => [_tipo]),
      ocurrenciasDeSemanaProvider.overrideWith((ref) async => ocurrencias),
      crearEventoAgendaProvider.overrideWithValue(_crearNoop),
      modificarEventoAgendaProvider.overrideWithValue(_modificarNoop),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

/// Monta el formulario como ruta apilada (para que el `pop` posterior al
/// guardado tenga a dónde volver).
Future<void> _pushForm(
  WidgetTester tester,
  ProviderContainer container, {
  int? eventId,
}) async {
  final navKey = GlobalKey<NavigatorState>();
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        navigatorKey: navKey,
        home: const Scaffold(body: SizedBox.shrink()),
      ),
    ),
  );
  navKey.currentState!.push(
    MaterialPageRoute(builder: (_) => AgendaEventScreen(eventId: eventId)),
  );
  await tester.pumpAndSettle();
}

/// Toca el botón de guardado, que vive al final del formulario scrolleable.
Future<void> _tapGuardar(WidgetTester tester, String label) async {
  await tester.ensureVisible(find.text(label));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

void main() {
  group('AgendaEventScreen', () {
    testWidgets('al crear un evento la agenda salta a su día y semana', (
      tester,
    ) async {
      final container = _container();

      // La agenda está mirando una semana lejana.
      container.read(semanaSeleccionadaProvider.notifier).state = _lunesLejano;
      container.read(diaSeleccionadoProvider.notifier).state = _lunesLejano;

      await _pushForm(tester, container);

      // El formulario arranca con la fecha de hoy.
      await tester.enterText(
        find.byType(TextFormField).first,
        'Control cardiológico',
      );
      await tester.pump();
      await _tapGuardar(tester, 'Crear evento');

      expect(container.read(diaSeleccionadoProvider), _hoy);
      expect(container.read(semanaSeleccionadaProvider), _lunesDeEstaSemana);
    });

    testWidgets('al editar un evento se salta al día que tiene cargado', (
      tester,
    ) async {
      // El evento a editar es de otra semana (dentro de 10 días).
      final fechaEvento = _hoy.add(const Duration(days: 10, hours: 9));
      final container = _container(ocurrencias: [_ocurrencia(fechaEvento)]);

      container.read(semanaSeleccionadaProvider.notifier).state =
          _lunesDeEstaSemana;
      container.read(diaSeleccionadoProvider.notifier).state = _hoy;

      await _pushForm(tester, container, eventId: 7);

      // El formulario precargó el evento: se guarda sin tocar la fecha.
      expect(find.text('Guardar cambios'), findsOneWidget);
      await _tapGuardar(tester, 'Guardar cambios');

      expect(container.read(diaSeleccionadoProvider), _soloFecha(fechaEvento));
      expect(
        container.read(semanaSeleccionadaProvider),
        lunesDeLaSemana(fechaEvento),
      );
    });

    testWidgets('no mueve la agenda si el guardado falla', (tester) async {
      final container = ProviderContainer(
        overrides: [
          agendaPersonaContextProvider.overrideWith((ref) async => _persona),
          personaVisualizacionSeleccionadaProvider.overrideWith(
            (ref) async => _persona,
          ),
          tiposEventoAgendablesProvider.overrideWith((ref) async => [_tipo]),
          ocurrenciasDeSemanaProvider.overrideWith((ref) async => const []),
          crearEventoAgendaProvider.overrideWithValue(({
            required personaId,
            required titulo,
            descripcion,
            required tipoEventoId,
            required fechaHoraInicio,
            required duracionMinutos,
            required generarEventoSalud,
            minutosAnticipacionRecordatorio,
            frecuenciaRecurrenciaId,
            intervaloRecurrencia,
            fechaFinRecurrencia,
          }) async {
            throw Exception('sin conexión');
          }),
        ],
      );
      addTearDown(container.dispose);

      container.read(semanaSeleccionadaProvider.notifier).state = _lunesLejano;
      container.read(diaSeleccionadoProvider.notifier).state = _lunesLejano;

      await _pushForm(tester, container);

      await tester.enterText(find.byType(TextFormField).first, 'Control');
      await tester.pump();
      await _tapGuardar(tester, 'Crear evento');

      expect(container.read(diaSeleccionadoProvider), _lunesLejano);
      expect(container.read(semanaSeleccionadaProvider), _lunesLejano);
    });
  });
}
