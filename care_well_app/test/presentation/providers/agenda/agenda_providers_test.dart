import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/domain/repositories/repositories.dart';
import 'package:care_well_app/domain/notifications/notifications.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../_fakes/fake_notification_scheduler.dart';

// ─── Fixtures ─────────────────────────────────────────────────────────────────

final _persona = Persona(
  id: 12,
  nombre: 'Alicia',
  apellido: 'Rodríguez',
  documento: '5234100',
  fechaNacimiento: DateTime(1943, 7, 22),
);

final _tipoCita = TipoEvento(id: 1, descripcion: 'Cita Médica');
final _tipoMedicacion = TipoEvento(id: 2, descripcion: 'Medicación');
final _tipoNoAgendable = TipoEvento(
  id: 99,
  descripcion: 'Generado por el sistema',
  agendable: false,
);

OcurrenciaEventoAgenda _ocurrencia({
  required int eventoAgendaId,
  required DateTime inicio,
  int? minutosAnticipacion,
  int? personaId,
}) => OcurrenciaEventoAgenda(
  id: eventoAgendaId,
  eventoAgendaId: eventoAgendaId,
  personaId: personaId ?? _persona.id,
  titulo: 'Evento $eventoAgendaId',
  tipo: _tipoCita,
  fechaHoraInicio: inicio,
  fechaHoraFin: inicio.add(const Duration(minutes: 30)),
  esRecurrente: false,
  generarEventoSalud: false,
  minutosAnticipacionRecordatorio: minutosAnticipacion,
);

// ─── Fake repository ────────────────────────────────────────────────────────

class _FakeAgendaRepository implements AgendaRepository {
  List<OcurrenciaEventoAgenda> ocurrencias;
  List<TipoEvento> tipos;

  /// Ocurrencias segmentadas por `personaId`. Cuando está presente, tiene
  /// prioridad sobre [ocurrencias] (usado en los tests multi-persona).
  final Map<int, List<OcurrenciaEventoAgenda>> ocurrenciasPorPersona;

  int obtenerOcurrenciasCount = 0;
  DateTime? ultimoDesde;
  DateTime? ultimoHasta;
  final List<int> personaIdsConsultados = [];
  int? eliminadoId;

  _FakeAgendaRepository({
    List<OcurrenciaEventoAgenda>? ocurrencias,
    List<TipoEvento>? tipos,
    Map<int, List<OcurrenciaEventoAgenda>>? ocurrenciasPorPersona,
  }) : ocurrencias = ocurrencias ?? [],
       tipos = tipos ?? [],
       ocurrenciasPorPersona = ocurrenciasPorPersona ?? {};

  @override
  Future<List<OcurrenciaEventoAgenda>> obtenerOcurrencias({
    required int personaId,
    required DateTime desde,
    required DateTime hasta,
  }) async {
    obtenerOcurrenciasCount++;
    personaIdsConsultados.add(personaId);
    ultimoDesde = desde;
    ultimoHasta = hasta;
    // Copia defensiva: el provider ordena la lista in-place.
    if (ocurrenciasPorPersona.isNotEmpty) {
      return List.of(ocurrenciasPorPersona[personaId] ?? const []);
    }
    return List.of(ocurrencias);
  }

  @override
  Future<void> crearEvento({
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

  @override
  Future<void> modificarEvento({
    required int eventoAgendaId,
    required String titulo,
    String? descripcion,
    required int tipoEventoId,
    required DateTime fechaHoraInicio,
    required int duracionMinutos,
    required bool generarEventoSalud,
    int? minutosAnticipacionRecordatorio,
  }) async {}

  @override
  Future<void> eliminarEvento(int eventoAgendaId) async {
    eliminadoId = eventoAgendaId;
  }

  @override
  Future<void> cancelarOcurrencia({
    required int eventoAgendaId,
    required DateTime fechaOcurrencia,
  }) async {}
}

// ─── Helper ───────────────────────────────────────────────────────────────────

ProviderContainer _makeContainer({
  required _FakeAgendaRepository repo,
  required FakeNotificationScheduler scheduler,
  Persona? persona,
  List<PersonaContextOption>? seleccionables,
  AgendaSyncThrottle? throttle,
}) {
  // Por defecto, el universo de personas seleccionables lo compone la persona
  // de contexto (si existe), para mantener el comportamiento de los tests
  // preexistentes que solo pasaban `persona`.
  final opciones =
      seleccionables ??
      (persona == null
          ? const <PersonaContextOption>[]
          : [
              PersonaContextOption(
                persona: persona,
                rol: PersonaContextRol.propio,
              ),
            ]);

  return ProviderContainer(
    overrides: [
      agendaPersonaContextProvider.overrideWith((ref) async => persona),
      personasSeleccionablesProvider.overrideWith((ref) async => opciones),
      agendaRepositoryProvider.overrideWithValue(repo),
      notificationSchedulerProvider.overrideWithValue(scheduler),
      tiposEventoProvider.overrideWith((ref) async => repo.tipos),
      if (throttle != null)
        agendaSyncThrottleProvider.overrideWithValue(throttle),
    ],
  );
}

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('agenda_providers', () {
    group('semanaSeleccionadaProvider / diaSeleccionadoProvider', () {
      test('por defecto apuntan al lunes de esta semana y a hoy', () async {
        final container = _makeContainer(
          repo: _FakeAgendaRepository(),
          scheduler: FakeNotificationScheduler(),
          persona: _persona,
        );
        addTearDown(container.dispose);

        final hoy = DateTime.now();
        final hoyTruncado = DateTime(hoy.year, hoy.month, hoy.day);
        final lunes = hoyTruncado.subtract(Duration(days: hoy.weekday - 1));

        expect(container.read(semanaSeleccionadaProvider), lunes);
        expect(container.read(diaSeleccionadoProvider), hoyTruncado);
      });

      test('lunesDeLaSemana trunca la hora y retrocede al lunes', () {
        // Jueves 13/08/2026 a las 21:45.
        expect(
          lunesDeLaSemana(DateTime(2026, 8, 13, 21, 45)),
          DateTime(2026, 8, 10),
        );
        // Un lunes se devuelve a sí mismo.
        expect(
          lunesDeLaSemana(DateTime(2026, 8, 10, 3)),
          DateTime(2026, 8, 10),
        );
        // Un domingo pertenece a la semana que empezó el lunes anterior.
        expect(lunesDeLaSemana(DateTime(2026, 8, 16)), DateTime(2026, 8, 10));
      });
    });

    group('ocurrenciasDeSemanaProvider', () {
      test('calcula el rango [lunes, lunes + 7 días)', () async {
        final repo = _FakeAgendaRepository();
        final container = _makeContainer(
          repo: repo,
          scheduler: FakeNotificationScheduler(),
          persona: _persona,
        );
        addTearDown(container.dispose);

        container.read(semanaSeleccionadaProvider.notifier).state = DateTime(
          2026,
          8,
          10,
        );

        await container.read(ocurrenciasDeSemanaProvider.future);

        expect(repo.ultimoDesde, DateTime(2026, 8, 10));
        expect(repo.ultimoHasta, DateTime(2026, 8, 17));
      });

      test('retorna lista vacía cuando no hay persona de contexto', () async {
        final repo = _FakeAgendaRepository(
          ocurrencias: [
            _ocurrencia(eventoAgendaId: 1, inicio: DateTime(2026, 8, 11)),
          ],
        );
        final container = _makeContainer(
          repo: repo,
          scheduler: FakeNotificationScheduler(),
          persona: null,
        );
        addTearDown(container.dispose);

        final result = await container.read(ocurrenciasDeSemanaProvider.future);

        expect(result, isEmpty);
        expect(repo.obtenerOcurrenciasCount, 0);
      });

      test('ordena las ocurrencias por fechaHoraInicio ascendente', () async {
        final repo = _FakeAgendaRepository(
          ocurrencias: [
            _ocurrencia(eventoAgendaId: 2, inicio: DateTime(2026, 8, 14, 15)),
            _ocurrencia(eventoAgendaId: 1, inicio: DateTime(2026, 8, 11, 9)),
            _ocurrencia(eventoAgendaId: 3, inicio: DateTime(2026, 8, 12, 12)),
          ],
        );
        final container = _makeContainer(
          repo: repo,
          scheduler: FakeNotificationScheduler(),
          persona: _persona,
        );
        addTearDown(container.dispose);

        final result = await container.read(ocurrenciasDeSemanaProvider.future);

        expect(result.map((o) => o.eventoAgendaId).toList(), [1, 3, 2]);
      });

      test('se recalcula al cambiar de semana', () async {
        final repo = _FakeAgendaRepository();
        final container = _makeContainer(
          repo: repo,
          scheduler: FakeNotificationScheduler(),
          persona: _persona,
        );
        addTearDown(container.dispose);

        await container.read(ocurrenciasDeSemanaProvider.future);
        final antes = repo.obtenerOcurrenciasCount;

        // La semana destino se deriva de la actual en vez de fijarse a una
        // fecha: con `DateTime(2026, 8, 17)` el test se rompía cada vez que ese
        // lunes era el de la semana en curso, porque escribir el mismo valor en
        // un StateProvider no notifica y el provider nunca se recalculaba.
        final otraSemana = container
            .read(semanaSeleccionadaProvider)
            .add(const Duration(days: 7));
        container.read(semanaSeleccionadaProvider.notifier).state = otraSemana;
        await container.read(ocurrenciasDeSemanaProvider.future);

        expect(repo.obtenerOcurrenciasCount, greaterThan(antes));
        expect(repo.ultimoDesde, otraSemana);
      });
    });

    group('proximaOcurrenciaProvider', () {
      test(
        'consulta desde el día siguiente al seleccionado y por 30 días',
        () async {
          final repo = _FakeAgendaRepository();
          final container = _makeContainer(
            repo: repo,
            scheduler: FakeNotificationScheduler(),
            persona: _persona,
          );
          addTearDown(container.dispose);

          container.read(diaSeleccionadoProvider.notifier).state = DateTime(
            2026,
            8,
            13,
          );

          await container.read(proximaOcurrenciaProvider.future);

          expect(repo.ultimoDesde, DateTime(2026, 8, 14));
          expect(repo.ultimoHasta, DateTime(2026, 9, 13));
        },
      );

      test('devuelve la ocurrencia más próxima', () async {
        final repo = _FakeAgendaRepository(
          ocurrencias: [
            _ocurrencia(eventoAgendaId: 9, inicio: DateTime(2026, 8, 20, 10)),
            _ocurrencia(eventoAgendaId: 7, inicio: DateTime(2026, 8, 15, 16)),
          ],
        );
        final container = _makeContainer(
          repo: repo,
          scheduler: FakeNotificationScheduler(),
          persona: _persona,
        );
        addTearDown(container.dispose);

        container.read(diaSeleccionadoProvider.notifier).state = DateTime(
          2026,
          8,
          13,
        );

        final proxima = await container.read(proximaOcurrenciaProvider.future);

        expect(proxima?.eventoAgendaId, 7);
      });

      test('devuelve null cuando no hay ocurrencias posteriores', () async {
        final container = _makeContainer(
          repo: _FakeAgendaRepository(),
          scheduler: FakeNotificationScheduler(),
          persona: _persona,
        );
        addTearDown(container.dispose);

        expect(await container.read(proximaOcurrenciaProvider.future), isNull);
      });

      test('devuelve null cuando no hay persona de contexto', () async {
        final repo = _FakeAgendaRepository(
          ocurrencias: [
            _ocurrencia(eventoAgendaId: 1, inicio: DateTime(2026, 8, 15)),
          ],
        );
        final container = _makeContainer(
          repo: repo,
          scheduler: FakeNotificationScheduler(),
          persona: null,
        );
        addTearDown(container.dispose);

        expect(await container.read(proximaOcurrenciaProvider.future), isNull);
        expect(repo.obtenerOcurrenciasCount, 0);
      });
    });

    group('tiposEventoAgendablesProvider', () {
      test('filtra solo los tipos con agendable == true', () async {
        final repo = _FakeAgendaRepository(
          tipos: [_tipoCita, _tipoMedicacion, _tipoNoAgendable],
        );
        final container = _makeContainer(
          repo: repo,
          scheduler: FakeNotificationScheduler(),
          persona: _persona,
        );
        addTearDown(container.dispose);

        final agendables = await container.read(
          tiposEventoAgendablesProvider.future,
        );

        expect(agendables.map((t) => t.id).toList(), [1, 2]);
        expect(agendables.every((t) => t.agendable), isTrue);
      });
    });

    group('eliminarEventoAgendaProvider', () {
      test(
        'elimina en el repo, invalida ocurrencias y resincroniza notificaciones',
        () async {
          final scheduler = FakeNotificationScheduler();
          final repo = _FakeAgendaRepository();
          final container = _makeContainer(
            repo: repo,
            scheduler: scheduler,
            persona: _persona,
          );
          addTearDown(container.dispose);

          // Precarga las vistas de ocurrencias para observar la invalidación.
          await container.read(ocurrenciasDeSemanaProvider.future);
          await container.read(proximaOcurrenciaProvider.future);
          final llamadasPrevias = repo.obtenerOcurrenciasCount;

          await container.read(eliminarEventoAgendaProvider)(77);

          // Se eliminó en el repo.
          expect(repo.eliminadoId, 77);
          // Se resincronizaron notificaciones (cancelAll + relectura de ocurrencias).
          expect(scheduler.cancelAllCount, 1);
          expect(repo.obtenerOcurrenciasCount, greaterThan(llamadasPrevias));

          // Al releer, ambas vistas vuelven a consultar (fueron invalidadas).
          final antes = repo.obtenerOcurrenciasCount;
          await container.read(ocurrenciasDeSemanaProvider.future);
          await container.read(proximaOcurrenciaProvider.future);
          expect(repo.obtenerOcurrenciasCount, antes + 2);
        },
      );
    });

    group('sincronizarNotificacionesAgendaProvider', () {
      test(
        'cancela todo antes de programar y solo agenda ocurrencias futuras con anticipación',
        () async {
          final ahora = DateTime.now();
          final futuraConRecordatorio = _ocurrencia(
            eventoAgendaId: 10,
            inicio: ahora.add(const Duration(days: 2)),
            minutosAnticipacion: 30,
          );
          final futuraSinRecordatorio = _ocurrencia(
            eventoAgendaId: 20,
            inicio: ahora.add(const Duration(days: 3)),
            minutosAnticipacion: null,
          );
          final pasadaConRecordatorio = _ocurrencia(
            eventoAgendaId: 30,
            inicio: ahora.subtract(const Duration(days: 1)),
            minutosAnticipacion: 30,
          );
          final scheduler = FakeNotificationScheduler();
          final repo = _FakeAgendaRepository(
            ocurrencias: [
              futuraConRecordatorio,
              futuraSinRecordatorio,
              pasadaConRecordatorio,
            ],
          );
          final container = _makeContainer(
            repo: repo,
            scheduler: scheduler,
            persona: _persona,
          );
          addTearDown(container.dispose);

          await container.read(sincronizarNotificacionesAgendaProvider)(
            motivo: SyncMotivo.ingreso,
          );

          // cancelAll se invocó exactamente una vez, antes de programar.
          expect(scheduler.cancelAllCount, 1);

          // Solo se programó la ocurrencia futura con anticipación configurada.
          final idEsperado = NotificationId.forOcurrencia(
            futuraConRecordatorio.eventoAgendaId,
            futuraConRecordatorio.fechaHoraInicio,
          );
          expect(scheduler.scheduled, [idEsperado]);
        },
      );

      test('no programa nada cuando no hay personas seleccionables', () async {
        final scheduler = FakeNotificationScheduler();
        final repo = _FakeAgendaRepository(
          ocurrencias: [
            _ocurrencia(
              eventoAgendaId: 10,
              inicio: DateTime.now().add(const Duration(days: 2)),
              minutosAnticipacion: 30,
            ),
          ],
        );
        final container = _makeContainer(
          repo: repo,
          scheduler: scheduler,
          persona: null,
          seleccionables: const [],
        );
        addTearDown(container.dispose);

        await container.read(sincronizarNotificacionesAgendaProvider)(
          motivo: SyncMotivo.ingreso,
        );

        expect(scheduler.cancelAllCount, 0);
        expect(scheduler.scheduled, isEmpty);
        expect(repo.obtenerOcurrenciasCount, 0);
      });

      test(
        'programa los recordatorios de TODAS las personas seleccionables',
        () async {
          final ahora = DateTime.now();
          final otraPersona = Persona(
            id: 99,
            nombre: 'Bruno',
            apellido: 'Pérez',
            documento: '4010203',
            fechaNacimiento: DateTime(1950, 3, 1),
          );

          final ocuAlicia = _ocurrencia(
            eventoAgendaId: 10,
            inicio: ahora.add(const Duration(days: 2)),
            minutosAnticipacion: 30,
            personaId: _persona.id,
          );
          final ocuBruno = _ocurrencia(
            eventoAgendaId: 20,
            inicio: ahora.add(const Duration(days: 3)),
            minutosAnticipacion: 15,
            personaId: otraPersona.id,
          );

          final scheduler = FakeNotificationScheduler();
          final repo = _FakeAgendaRepository(
            ocurrenciasPorPersona: {
              _persona.id: [ocuAlicia],
              otraPersona.id: [ocuBruno],
            },
          );
          final container = _makeContainer(
            repo: repo,
            scheduler: scheduler,
            seleccionables: [
              PersonaContextOption(
                persona: _persona,
                rol: PersonaContextRol.propio,
              ),
              PersonaContextOption(
                persona: otraPersona,
                rol: PersonaContextRol.responsable,
              ),
            ],
          );
          addTearDown(container.dispose);

          await container.read(sincronizarNotificacionesAgendaProvider)(
            motivo: SyncMotivo.ingreso,
          );

          // cancelAll una sola vez, aunque haya varias personas.
          expect(scheduler.cancelAllCount, 1);
          // Se consultó a ambas personas.
          expect(repo.personaIdsConsultados, containsAll([_persona.id, 99]));
          // Se programaron los recordatorios de ambas.
          expect(scheduler.scheduled, [
            NotificationId.forOcurrencia(
              ocuAlicia.eventoAgendaId,
              ocuAlicia.fechaHoraInicio,
            ),
            NotificationId.forOcurrencia(
              ocuBruno.eventoAgendaId,
              ocuBruno.fechaHoraInicio,
            ),
          ]);
        },
      );

      group('throttle del motivo resume', () {
        test('resume se saltea si la última corrida fue reciente', () async {
          final scheduler = FakeNotificationScheduler();
          final repo = _FakeAgendaRepository(
            ocurrencias: [
              _ocurrencia(
                eventoAgendaId: 10,
                inicio: DateTime.now().add(const Duration(days: 2)),
                minutosAnticipacion: 30,
              ),
            ],
          );
          // Reloj fijo: la última corrida fue hace 5 min (< ventana de 15).
          final ahora = DateTime(2026, 7, 8, 10, 0);
          final throttle = AgendaSyncThrottle(clock: () => ahora)
            ..marcarCorrida();
          final container = _makeContainer(
            repo: repo,
            scheduler: scheduler,
            persona: _persona,
            throttle: throttle,
          );
          addTearDown(container.dispose);

          await container.read(sincronizarNotificacionesAgendaProvider)(
            motivo: SyncMotivo.resume,
          );

          // No corrió: ni cancelAll ni consultas al repo.
          expect(scheduler.cancelAllCount, 0);
          expect(scheduler.scheduled, isEmpty);
          expect(repo.obtenerOcurrenciasCount, 0);
        });

        test('resume corre pasada la ventana del throttle', () async {
          final scheduler = FakeNotificationScheduler();
          final ocu = _ocurrencia(
            eventoAgendaId: 10,
            inicio: DateTime.now().add(const Duration(days: 2)),
            minutosAnticipacion: 30,
          );
          final repo = _FakeAgendaRepository(ocurrencias: [ocu]);
          // Reloj que avanza 20 min entre la marca y la evaluación.
          var t = DateTime(2026, 7, 8, 10, 0);
          final throttle = AgendaSyncThrottle(clock: () => t)..marcarCorrida();
          t = DateTime(2026, 7, 8, 10, 20);
          final container = _makeContainer(
            repo: repo,
            scheduler: scheduler,
            persona: _persona,
            throttle: throttle,
          );
          addTearDown(container.dispose);

          await container.read(sincronizarNotificacionesAgendaProvider)(
            motivo: SyncMotivo.resume,
          );

          expect(scheduler.cancelAllCount, 1);
          expect(scheduler.scheduled, [
            NotificationId.forOcurrencia(
              ocu.eventoAgendaId,
              ocu.fechaHoraInicio,
            ),
          ]);
        });

        test('ingreso corre siempre, aunque el throttle esté fresco', () async {
          final scheduler = FakeNotificationScheduler();
          final ocu = _ocurrencia(
            eventoAgendaId: 10,
            inicio: DateTime.now().add(const Duration(days: 2)),
            minutosAnticipacion: 30,
          );
          final repo = _FakeAgendaRepository(ocurrencias: [ocu]);
          final ahora = DateTime(2026, 7, 8, 10, 0);
          final throttle = AgendaSyncThrottle(clock: () => ahora)
            ..marcarCorrida();
          final container = _makeContainer(
            repo: repo,
            scheduler: scheduler,
            persona: _persona,
            throttle: throttle,
          );
          addTearDown(container.dispose);

          await container.read(sincronizarNotificacionesAgendaProvider)(
            motivo: SyncMotivo.ingreso,
          );

          expect(scheduler.cancelAllCount, 1);
          expect(scheduler.scheduled, [
            NotificationId.forOcurrencia(
              ocu.eventoAgendaId,
              ocu.fechaHoraInicio,
            ),
          ]);
        });
      });
    });
  });
}
