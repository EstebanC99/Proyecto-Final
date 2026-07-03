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
}) => OcurrenciaEventoAgenda(
  id: eventoAgendaId,
  eventoAgendaId: eventoAgendaId,
  personaId: _persona.id,
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

  int obtenerOcurrenciasCount = 0;
  DateTime? ultimoDesde;
  DateTime? ultimoHasta;
  int? eliminadoId;

  _FakeAgendaRepository({
    List<OcurrenciaEventoAgenda>? ocurrencias,
    List<TipoEvento>? tipos,
  }) : ocurrencias = ocurrencias ?? [],
       tipos = tipos ?? [];

  @override
  Future<List<OcurrenciaEventoAgenda>> obtenerOcurrencias({
    required int personaId,
    required DateTime desde,
    required DateTime hasta,
  }) async {
    obtenerOcurrenciasCount++;
    ultimoDesde = desde;
    ultimoHasta = hasta;
    // Copia defensiva: el provider ordena la lista in-place.
    return List.of(ocurrencias);
  }

  @override
  Future<List<TipoEvento>> obtenerTiposEvento() async => tipos;

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
}) {
  return ProviderContainer(
    overrides: [
      agendaPersonaContextProvider.overrideWith((ref) async => persona),
      agendaRepositoryProvider.overrideWithValue(repo),
      notificationSchedulerProvider.overrideWithValue(scheduler),
    ],
  );
}

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('agenda_providers', () {
    group('ocurrenciasDelMesProvider', () {
      test(
        'calcula el rango [primer día del mes, primer día del mes siguiente)',
        () async {
          final repo = _FakeAgendaRepository();
          final container = _makeContainer(
            repo: repo,
            scheduler: FakeNotificationScheduler(),
            persona: _persona,
          );
          addTearDown(container.dispose);

          container.read(mesSeleccionadoProvider.notifier).state = DateTime(
            2026,
            7,
            1,
          );

          await container.read(ocurrenciasDelMesProvider.future);

          expect(repo.ultimoDesde, DateTime(2026, 7, 1));
          expect(repo.ultimoHasta, DateTime(2026, 8, 1));
        },
      );

      test(
        'el rango de diciembre pasa correctamente a enero del año siguiente',
        () async {
          final repo = _FakeAgendaRepository();
          final container = _makeContainer(
            repo: repo,
            scheduler: FakeNotificationScheduler(),
            persona: _persona,
          );
          addTearDown(container.dispose);

          container.read(mesSeleccionadoProvider.notifier).state = DateTime(
            2026,
            12,
            1,
          );

          await container.read(ocurrenciasDelMesProvider.future);

          expect(repo.ultimoDesde, DateTime(2026, 12, 1));
          expect(repo.ultimoHasta, DateTime(2027, 1, 1));
        },
      );

      test('retorna lista vacía cuando no hay persona de contexto', () async {
        final repo = _FakeAgendaRepository(
          ocurrencias: [
            _ocurrencia(eventoAgendaId: 1, inicio: DateTime(2026, 7, 10)),
          ],
        );
        final container = _makeContainer(
          repo: repo,
          scheduler: FakeNotificationScheduler(),
          persona: null,
        );
        addTearDown(container.dispose);

        final result = await container.read(ocurrenciasDelMesProvider.future);

        expect(result, isEmpty);
        expect(repo.obtenerOcurrenciasCount, 0);
      });

      test('ordena las ocurrencias por fechaHoraInicio ascendente', () async {
        final tarde = _ocurrencia(
          eventoAgendaId: 2,
          inicio: DateTime(2026, 7, 20, 15),
        );
        final temprano = _ocurrencia(
          eventoAgendaId: 1,
          inicio: DateTime(2026, 7, 5, 9),
        );
        final medio = _ocurrencia(
          eventoAgendaId: 3,
          inicio: DateTime(2026, 7, 12, 12),
        );
        final repo = _FakeAgendaRepository(
          ocurrencias: [tarde, temprano, medio],
        );
        final container = _makeContainer(
          repo: repo,
          scheduler: FakeNotificationScheduler(),
          persona: _persona,
        );
        addTearDown(container.dispose);

        final result = await container.read(ocurrenciasDelMesProvider.future);

        expect(result.map((o) => o.eventoAgendaId).toList(), [1, 3, 2]);
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

          // Precarga las ocurrencias del mes para poder observar la invalidación.
          await container.read(ocurrenciasDelMesProvider.future);
          final llamadasPrevias = repo.obtenerOcurrenciasCount;

          await container.read(eliminarEventoAgendaProvider)(77);

          // Se eliminó en el repo.
          expect(repo.eliminadoId, 77);
          // Se resincronizaron notificaciones (cancelAll + relectura de ocurrencias).
          expect(scheduler.cancelAllCount, 1);
          expect(repo.obtenerOcurrenciasCount, greaterThan(llamadasPrevias));

          // Al releer, ocurrenciasDelMesProvider vuelve a consultar (fue invalidado).
          final antes = repo.obtenerOcurrenciasCount;
          await container.read(ocurrenciasDelMesProvider.future);
          expect(repo.obtenerOcurrenciasCount, greaterThan(antes));
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

          await container.read(sincronizarNotificacionesAgendaProvider)();

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

      test('no programa nada cuando no hay persona de contexto', () async {
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
        );
        addTearDown(container.dispose);

        await container.read(sincronizarNotificacionesAgendaProvider)();

        expect(scheduler.cancelAllCount, 0);
        expect(scheduler.scheduled, isEmpty);
        expect(repo.obtenerOcurrenciasCount, 0);
      });
    });
  });
}
