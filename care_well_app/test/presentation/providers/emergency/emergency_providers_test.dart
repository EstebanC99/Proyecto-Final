import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/domain/repositories/repositories.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
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

final _personaCarlos = Persona(
  id: 3,
  nombre: 'Carlos',
  apellido: 'Pérez',
  documento: '30000003',
  fechaNacimiento: DateTime(1985, 3, 15),
);

final _permisosEmergencia = [
  PermisoCuidado(
    id: PermisosCuidadoConst.activarEmergencia,
    descripcion: 'Activar emergencia',
  ),
];

final _usuarioDemoMaria = Usuario(
  id: 101,
  persona: _personaMaria,
  contrasena: 'hash123',
  estado: estadoUsuarioActivo,
);

AsignacionCuidado _asignacion(
  int id,
  Persona colaborador, {
  RolCuidado? rol,
  List<PermisoCuidado>? permisos,
}) => AsignacionCuidado(
  id: id,
  personaCuidada: _personaAlicia,
  colaborador: colaborador,
  rol: rol ?? rolCuidadoResponsable,
  estado: estadoAsignacionActiva,
  fechaAlta: DateTime(2024, 1, 8),
  permisos: permisos ?? _permisosEmergencia,
);

// ─── Fakes ────────────────────────────────────────────────────────────────────

class _FakeCareTeamRepository implements CareTeamRepository {
  final List<AsignacionCuidado> _asignaciones;

  _FakeCareTeamRepository(this._asignaciones);

  @override
  Future<List<AsignacionCuidado>> getAsignacionesByPersonaCuidada(
    int personaCuidadaId,
  ) async => _asignaciones
      .where((a) => a.personaCuidada.id == personaCuidadaId)
      .toList();

  @override
  Future<List<AsignacionCuidado>> getAsignacionesByColaborador(
    int colaboradorId,
  ) async =>
      _asignaciones.where((a) => a.colaborador.id == colaboradorId).toList();

  @override
  Future<AsignacionCuidado> crearAsignacion(AsignacionCuidado a) async => a;

  @override
  Future<AsignacionCuidado> actualizarAsignacion(AsignacionCuidado a) async =>
      a;

  @override
  Future<void> eliminarAsignacion(int id) async {}

  @override
  Future<List<RolCuidado>> getRoles() async => [rolCuidadoResponsable];

  @override
  Future<RolCuidado> getRolById(int rolId) async => rolCuidadoResponsable;
}

class _FakeEmergencyRepository implements EmergencyRepository {
  final List<Emergencia> _emergencias = [];
  int _nextId = 10000;

  @override
  Future<Emergencia> activarEmergencia({
    required int personaId,
    String? descripcion,
  }) async {
    final emg = Emergencia(
      id: _nextId++,
      persona: _personaAlicia,
      fechaHora: DateTime.now(),
    );
    _emergencias.add(emg);
    return emg;
  }

  @override
  Future<List<Emergencia>> getEmergenciasByPersona(int personaId) async =>
      _emergencias.where((e) => e.persona.id == personaId).toList();

  @override
  Future<Emergencia> marcarAtendida(int emergenciaId) async =>
      _emergencias.firstWhere((e) => e.id == emergenciaId);
}

// ─── Helper ───────────────────────────────────────────────────────────────────

ProviderContainer _makeContainer({
  required List<AsignacionCuidado> asignaciones,
  required FakeNotificationScheduler scheduler,
}) {
  final fakeEmergencyRepo = _FakeEmergencyRepository();
  return ProviderContainer(
    overrides: [
      authStateProvider.overrideWith(
        (ref) =>
            AuthNotifier(ref.watch(authRepositoryProvider))
              ..state = AsyncValue.data(_usuarioDemoMaria),
      ),
      careTeamContextPersonaProvider.overrideWith(
        (ref) async => _personaAlicia,
      ),
      careTeamRepositoryProvider.overrideWithValue(
        _FakeCareTeamRepository(asignaciones),
      ),
      emergencyRepositoryProvider.overrideWithValue(fakeEmergencyRepo),
      notificationSchedulerProvider.overrideWithValue(scheduler),
    ],
  );
}

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('emergency_providers', () {
    group('equipoEmergenciaProvider', () {
      test('retorna solo asignaciones activas', () async {
        final asignaciones = [
          _asignacion(401, _personaMaria),
          _asignacion(402, _personaCarlos),
          AsignacionCuidado(
            id: 403,
            personaCuidada: _personaAlicia,
            colaborador: _personaCarlos,
            rol: rolCuidadoResponsable,
            estado: estadoAsignacionInactiva,
            fechaAlta: DateTime.now(),
          ),
        ];
        final scheduler = FakeNotificationScheduler();
        final container = _makeContainer(
          asignaciones: asignaciones,
          scheduler: scheduler,
        );
        addTearDown(container.dispose);

        final equipo = await container.read(equipoEmergenciaProvider.future);
        expect(equipo.length, 2);
        expect(
          equipo.every((a) => a.estado.id == EstadosAsignacionConst.activa),
          isTrue,
        );
      });
    });

    group('activarEmergenciaProvider', () {
      test(
        'llama showImmediateNotification una vez por miembro del equipo',
        () async {
          final miembros = [
            _asignacion(401, _personaMaria),
            _asignacion(402, _personaCarlos),
          ];
          final scheduler = FakeNotificationScheduler();
          final container = _makeContainer(
            asignaciones: miembros,
            scheduler: scheduler,
          );
          addTearDown(container.dispose);

          // Pre-cargar equipo
          await container.read(equipoEmergenciaProvider.future);

          final accion = container.read(activarEmergenciaProvider);
          await accion();

          // Debe haber enviado una notificación por cada miembro activo
          expect(scheduler.shown.length, equals(miembros.length));
        },
      );

      test('registra la emergencia en el repositorio', () async {
        final scheduler = FakeNotificationScheduler();
        final container = _makeContainer(
          asignaciones: [_asignacion(401, _personaMaria)],
          scheduler: scheduler,
        );
        addTearDown(container.dispose);

        await container.read(equipoEmergenciaProvider.future);
        final emergencia = await container.read(activarEmergenciaProvider)();

        expect(emergencia.id, greaterThan(0));
        expect(emergencia.persona.id, _personaAlicia.id);
      });
    });

    group('puedeActivarEmergenciaProvider', () {
      test('retorna true con permiso activarEmergencia', () async {
        final scheduler = FakeNotificationScheduler();
        final container = _makeContainer(
          asignaciones: [_asignacion(401, _personaMaria)],
          scheduler: scheduler,
        );
        addTearDown(container.dispose);

        final puede = await container.read(
          puedeActivarEmergenciaProvider.future,
        );
        expect(puede, isTrue);
      });

      test(
        'retorna false sin asignación para persona ajena (Alicia)',
        () async {
          final scheduler = FakeNotificationScheduler();
          final container = _makeContainer(
            asignaciones: [],
            scheduler: scheduler,
          );
          addTearDown(container.dispose);

          final puede = await container.read(
            puedeActivarEmergenciaProvider.future,
          );
          expect(puede, isFalse);
        },
      );

      test(
        'retorna true cuando el contexto es el propio usuario sin asignaciones',
        () async {
          // Sobreescribir el contexto a María (propio usuario).
          final scheduler = FakeNotificationScheduler();
          final container = ProviderContainer(
            overrides: [
              authStateProvider.overrideWith(
                (ref) =>
                    AuthNotifier(ref.watch(authRepositoryProvider))
                      ..state = AsyncValue.data(_usuarioDemoMaria),
              ),
              careTeamContextPersonaProvider.overrideWith(
                (ref) async => _personaMaria,
              ),
              careTeamRepositoryProvider.overrideWithValue(
                _FakeCareTeamRepository([]),
              ),
              emergencyRepositoryProvider.overrideWithValue(
                _FakeEmergencyRepository(),
              ),
              notificationSchedulerProvider.overrideWithValue(scheduler),
            ],
          );
          addTearDown(container.dispose);

          final puede = await container.read(
            puedeActivarEmergenciaProvider.future,
          );
          expect(puede, isTrue);
        },
      );
    });
  });
}
