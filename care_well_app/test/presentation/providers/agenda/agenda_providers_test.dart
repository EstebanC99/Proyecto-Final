import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/domain/repositories/repositories.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../_fakes/fake_notification_scheduler.dart';

// ─── Fixtures ─────────────────────────────────────────────────────────────────

final _personaAlicia = Persona(
  id: 'per_002',
  nombre: 'Alicia',
  apellido: 'Rodríguez',
);

final _personaMaria = Persona(
  id: 'per_001',
  nombre: 'María',
  apellido: 'García',
  email: 'maria@test.com',
);

final _permisosResponsable = [
  const Permiso(
    id: 'prm_003',
    codigo: CodigoPermiso.gestionarAgenda,
    descripcion: 'Gestionar agenda',
  ),
];

final _rolResponsable = Rol(
  id: 'rol_001',
  nombre: RolCuidado.responsable,
  permisos: _permisosResponsable,
);

final _rolCuidadorSinAgenda = Rol(
  id: 'rol_002',
  nombre: RolCuidado.cuidador,
  permisos: [], // sin permiso de agenda
);

AsignacionCuidado _asignacionMaria() => AsignacionCuidado(
  id: 'asi_003',
  personaCuidada: _personaAlicia,
  personaColaborador: _personaMaria,
  rol: _rolResponsable,
  estado: EstadoAsignacion.activa,
  fechaAlta: DateTime(2024, 1, 8),
);

final _usuarioDemoMaria = Usuario(
  id: 'usr_001',
  persona: _personaMaria,
  nombreUsuario: 'maria.garcia',
  estado: EstadoUsuario.activo,
);

// ─── Fake repositories ────────────────────────────────────────────────────────

class _FakeCareTeamRepository implements CareTeamRepository {
  final List<AsignacionCuidado> _asignaciones;

  _FakeCareTeamRepository(this._asignaciones);

  @override
  Future<List<AsignacionCuidado>> getAsignacionesByColaborador(
    String colaboradorId,
  ) async => _asignaciones
      .where((a) => a.personaColaborador.id == colaboradorId)
      .toList();

  @override
  Future<List<AsignacionCuidado>> getAsignacionesByPersonaCuidada(
    String personaCuidadaId,
  ) async => _asignaciones
      .where((a) => a.personaCuidada.id == personaCuidadaId)
      .toList();

  @override
  Future<AsignacionCuidado> crearAsignacion(AsignacionCuidado a) async => a;

  @override
  Future<AsignacionCuidado> actualizarAsignacion(AsignacionCuidado a) async =>
      a;

  @override
  Future<void> eliminarAsignacion(String id) async {}

  @override
  Future<List<Rol>> getRoles() async => [_rolResponsable];

  @override
  Future<Rol> getRolById(String rolId) async => _rolResponsable;
}

class _FakeAgendaRepository implements AgendaRepository {
  final List<EventoAgenda> _eventos;
  final List<Recordatorio> _recordatorios;

  _FakeAgendaRepository({
    List<EventoAgenda>? eventos,
    List<Recordatorio>? recordatorios,
  }) : _eventos = eventos ?? [],
       _recordatorios = recordatorios ?? [];

  @override
  Future<List<EventoAgenda>> getEventosByPersona(String personaId) async =>
      _eventos.where((e) => e.persona.id == personaId).toList();

  @override
  Future<List<EventoAgenda>> getEventosByRango({
    required String personaId,
    required DateTime desde,
    required DateTime hasta,
  }) async => _eventos
      .where(
        (e) =>
            e.persona.id == personaId &&
            !e.fechaHoraInicio.isBefore(desde) &&
            !e.fechaHoraInicio.isAfter(hasta),
      )
      .toList();

  @override
  Future<EventoAgenda> crearEvento(EventoAgenda evento) async {
    _eventos.add(evento);
    return evento;
  }

  @override
  Future<EventoAgenda> actualizarEvento(EventoAgenda evento) async {
    final idx = _eventos.indexWhere((e) => e.id == evento.id);
    if (idx >= 0) _eventos[idx] = evento;
    return evento;
  }

  @override
  Future<void> eliminarEvento(String eventoId) async {
    _eventos.removeWhere((e) => e.id == eventoId);
    _recordatorios.removeWhere((r) => r.eventoAgenda.id == eventoId);
  }

  @override
  Future<List<Recordatorio>> getRecordatoriosByEvento(String eventoId) async =>
      _recordatorios.where((r) => r.eventoAgenda.id == eventoId).toList();

  @override
  Future<Recordatorio> crearRecordatorio(Recordatorio r) async {
    _recordatorios.add(r);
    return r;
  }

  @override
  Future<Recordatorio> marcarEnviado(String recordatorioId) async {
    final idx = _recordatorios.indexWhere((r) => r.id == recordatorioId);
    final r = _recordatorios[idx];
    final actualizado = r.copyWith(enviado: true);
    _recordatorios[idx] = actualizado;
    return actualizado;
  }

  @override
  Future<void> eliminarRecordatorio(String recordatorioId) async {
    _recordatorios.removeWhere((r) => r.id == recordatorioId);
  }
}

// ─── Helper ───────────────────────────────────────────────────────────────────

ProviderContainer _buildContainer({
  List<AsignacionCuidado>? asignaciones,
  List<EventoAgenda>? eventos,
  FakeNotificationScheduler? scheduler,
}) {
  final asigs = asignaciones ?? [_asignacionMaria()];
  final fakeScheduler = scheduler ?? FakeNotificationScheduler();
  final fakePersonaRepo = _FakePersonaRepository([
    _personaMaria,
    _personaAlicia,
  ]);

  return ProviderContainer(
    overrides: [
      authStateProvider.overrideWith(
        (ref) =>
            AuthNotifier(ref.watch(authRepositoryProvider))
              ..state = AsyncValue.data(_usuarioDemoMaria),
      ),
      personaRepositoryProvider.overrideWithValue(fakePersonaRepo),
      careTeamRepositoryProvider.overrideWithValue(
        _FakeCareTeamRepository(asigs),
      ),
      agendaRepositoryProvider.overrideWithValue(
        _FakeAgendaRepository(eventos: eventos),
      ),
      notificationSchedulerProvider.overrideWithValue(fakeScheduler),
    ],
  );
}

class _FakePersonaRepository implements PersonaRepository {
  final List<Persona> _personas;
  _FakePersonaRepository(this._personas);

  @override
  Future<Persona> getById(String id) async =>
      _personas.firstWhere((p) => p.id == id);

  @override
  Future<List<Persona>> getDependientesByUsuario(String usuarioId) async => [];

  @override
  Future<Persona> crear(Persona p) async => p.copyWith(id: 'per_new');

  @override
  Future<Persona> actualizar(Persona p) async => p;

  @override
  Future<void> eliminar(String id) async {}
}

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('agendaEventosProvider', () {
    test('retorna lista vacía cuando no hay eventos', () async {
      final container = _buildContainer(eventos: []);
      addTearDown(container.dispose);

      final eventos = await container.read(agendaEventosProvider.future);
      expect(eventos, isEmpty);
    });

    test('retorna eventos ordenados cronológicamente', () async {
      final eventoTardio = EventoAgenda(
        id: 'evt_b',
        persona: _personaAlicia,
        creadoPor: _usuarioDemoMaria,
        titulo: 'Evento tardío',
        tipo: TipoEventoAgenda.otro,
        fechaHoraInicio: DateTime(2026, 6, 15, 10, 0),
      );
      final eventoTemprano = EventoAgenda(
        id: 'evt_a',
        persona: _personaAlicia,
        creadoPor: _usuarioDemoMaria,
        titulo: 'Evento temprano',
        tipo: TipoEventoAgenda.otro,
        fechaHoraInicio: DateTime(2026, 6, 10, 8, 0),
      );

      final container = _buildContainer(
        eventos: [eventoTardio, eventoTemprano],
      );
      addTearDown(container.dispose);

      final eventos = await container.read(agendaEventosProvider.future);

      expect(eventos.length, 2);
      expect(eventos[0].id, 'evt_a');
      expect(eventos[1].id, 'evt_b');
    });
  });

  group('puedeGestionarAgendaProvider', () {
    test('retorna true para usuario con permiso gestionarAgenda', () async {
      final container = _buildContainer();
      addTearDown(container.dispose);

      final puede = await container.read(puedeGestionarAgendaProvider.future);
      expect(puede, isTrue);
    });

    test(
      'retorna true cuando el contexto es el propio usuario (sin asignaciones)',
      () async {
        // Sin asignaciones: careTeamContextPersonaProvider resuelve a María (propio usuario).
        // esContextoPropioProvider debe retornar true → puedeGestionarAgenda = true.
        final container = _buildContainer(asignaciones: []);
        addTearDown(container.dispose);

        final puede = await container.read(puedeGestionarAgendaProvider.future);
        expect(puede, isTrue);
      },
    );

    test(
      'retorna false cuando no hay asignación activa para persona ajena',
      () async {
        // Sobreescribir el contexto a Alicia (persona ajena) sin asignaciones
        // → esContextoPropio = false y sin asignación → false.
        final container = ProviderContainer(
          overrides: [
            authStateProvider.overrideWith(
              (ref) =>
                  AuthNotifier(ref.watch(authRepositoryProvider))
                    ..state = AsyncValue.data(_usuarioDemoMaria),
            ),
            personaRepositoryProvider.overrideWithValue(
              _FakePersonaRepository([_personaMaria, _personaAlicia]),
            ),
            careTeamRepositoryProvider.overrideWithValue(
              _FakeCareTeamRepository([]),
            ),
            agendaRepositoryProvider.overrideWithValue(_FakeAgendaRepository()),
            notificationSchedulerProvider.overrideWithValue(
              FakeNotificationScheduler(),
            ),
            careTeamContextPersonaProvider.overrideWith(
              (ref) async => _personaAlicia,
            ),
          ],
        );
        addTearDown(container.dispose);

        final puede = await container.read(puedeGestionarAgendaProvider.future);
        expect(puede, isFalse);
      },
    );

    test('retorna false para cuidador sin permiso de agenda', () async {
      final asignacionSinPermiso = AsignacionCuidado(
        id: 'asi_sin',
        personaCuidada: _personaAlicia,
        personaColaborador: _personaMaria,
        rol: _rolCuidadorSinAgenda,
        estado: EstadoAsignacion.activa,
        fechaAlta: DateTime(2024, 1, 8),
      );

      // Sobreescribir el contexto a Alicia para que esContextoPropio = false.
      final container = ProviderContainer(
        overrides: [
          authStateProvider.overrideWith(
            (ref) =>
                AuthNotifier(ref.watch(authRepositoryProvider))
                  ..state = AsyncValue.data(_usuarioDemoMaria),
          ),
          personaRepositoryProvider.overrideWithValue(
            _FakePersonaRepository([_personaMaria, _personaAlicia]),
          ),
          careTeamRepositoryProvider.overrideWithValue(
            _FakeCareTeamRepository([asignacionSinPermiso]),
          ),
          agendaRepositoryProvider.overrideWithValue(_FakeAgendaRepository()),
          notificationSchedulerProvider.overrideWithValue(
            FakeNotificationScheduler(),
          ),
          careTeamContextPersonaProvider.overrideWith(
            (ref) async => _personaAlicia,
          ),
        ],
      );
      addTearDown(container.dispose);

      final puede = await container.read(puedeGestionarAgendaProvider.future);
      expect(puede, isFalse);
    });
  });

  group('crearEventoAgendaProvider', () {
    test(
      'crea el evento y programa notificación cuando conRecordatorio=true',
      () async {
        final scheduler = FakeNotificationScheduler();
        final container = _buildContainer(scheduler: scheduler);
        addTearDown(container.dispose);

        final crearFn = container.read(crearEventoAgendaProvider);
        final fechaFutura = DateTime(2027, 1, 15, 10, 0);

        await crearFn(
          personaCuidada: _personaAlicia,
          fechaHora: fechaFutura,
          descripcion: 'Visita al médico',
          conRecordatorio: true,
          creadoPor: _usuarioDemoMaria,
        );

        expect(scheduler.scheduled, hasLength(1));
      },
    );

    test('no programa notificación cuando conRecordatorio=false', () async {
      final scheduler = FakeNotificationScheduler();
      final container = _buildContainer(scheduler: scheduler);
      addTearDown(container.dispose);

      final crearFn = container.read(crearEventoAgendaProvider);
      final fechaFutura = DateTime(2027, 1, 15, 10, 0);

      await crearFn(
        personaCuidada: _personaAlicia,
        fechaHora: fechaFutura,
        descripcion: 'Visita al médico',
        conRecordatorio: false,
        creadoPor: _usuarioDemoMaria,
      );

      expect(scheduler.scheduled, isEmpty);
    });
  });

  group('agendaEventoByIdProvider', () {
    test('retorna el evento correcto por ID', () async {
      final evento = EventoAgenda(
        id: 'evt_x',
        persona: _personaAlicia,
        creadoPor: _usuarioDemoMaria,
        titulo: 'Evento X',
        tipo: TipoEventoAgenda.citaMedica,
        fechaHoraInicio: DateTime(2026, 6, 20, 9, 0),
      );

      final container = _buildContainer(eventos: [evento]);
      addTearDown(container.dispose);

      final resultado = await container.read(
        agendaEventoByIdProvider('evt_x').future,
      );
      expect(resultado, isNotNull);
      expect(resultado!.id, 'evt_x');
    });

    test('retorna null para ID inexistente', () async {
      final container = _buildContainer(eventos: []);
      addTearDown(container.dispose);

      final resultado = await container.read(
        agendaEventoByIdProvider('evt_nope').future,
      );
      expect(resultado, isNull);
    });
  });
}
