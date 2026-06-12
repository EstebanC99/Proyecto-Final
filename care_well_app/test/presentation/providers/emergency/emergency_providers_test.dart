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
);

final _personaCarlos = Persona(
  id: 'per_003',
  nombre: 'Carlos',
  apellido: 'Pérez',
);

final _rolResponsable = Rol(id: 'rol_001', nombre: RolCuidado.responsable);

final _permisosEmergencia = [
  const Permiso(
    id: 'prm_006',
    codigo: CodigoPermiso.activarEmergencia,
    descripcion: 'Activar emergencia',
  ),
];

final _usuarioDemoMaria = Usuario(
  id: 'usr_001',
  persona: _personaMaria,
  nombreUsuario: 'maria.garcia',
  estado: EstadoUsuario.activo,
);

AsignacionCuidado _asignacion(
  String id,
  Persona colaborador, {
  Rol? rol,
  List<Permiso>? permisos,
}) => AsignacionCuidado(
  id: id,
  personaCuidada: _personaAlicia,
  personaColaborador: colaborador,
  rol: rol ?? _rolResponsable,
  estado: EstadoAsignacion.activa,
  fechaAlta: DateTime(2024, 1, 8),
  permisos: permisos ?? _permisosEmergencia,
);

// ─── Fakes ────────────────────────────────────────────────────────────────────

class _FakeCareTeamRepository implements CareTeamRepository {
  final List<AsignacionCuidado> _asignaciones;

  _FakeCareTeamRepository(this._asignaciones);

  @override
  Future<List<AsignacionCuidado>> getAsignacionesByPersonaCuidada(
    String personaCuidadaId,
  ) async => _asignaciones
      .where((a) => a.personaCuidada.id == personaCuidadaId)
      .toList();

  @override
  Future<List<AsignacionCuidado>> getAsignacionesByColaborador(
    String colaboradorId,
  ) async => _asignaciones
      .where((a) => a.personaColaborador.id == colaboradorId)
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

class _FakeEmergencyRepository implements EmergencyRepository {
  final List<Emergencia> _emergencias = [];

  @override
  Future<Emergencia> activarEmergencia({
    required String personaId,
    String? descripcion,
  }) async {
    final emg = Emergencia(
      id: 'emg_test_${_emergencias.length}',
      persona: _personaAlicia,
      fechaHora: DateTime.now(),
    );
    _emergencias.add(emg);
    return emg;
  }

  @override
  Future<List<Emergencia>> getEmergenciasByPersona(String personaId) async =>
      _emergencias.where((e) => e.persona.id == personaId).toList();

  @override
  Future<Emergencia> marcarAtendida(String emergenciaId) async =>
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
          _asignacion('asi_001', _personaMaria),
          _asignacion('asi_002', _personaCarlos),
          AsignacionCuidado(
            id: 'asi_inac',
            personaCuidada: _personaAlicia,
            personaColaborador: _personaCarlos,
            rol: _rolResponsable,
            estado: EstadoAsignacion.inactiva,
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
          equipo.every((a) => a.estado == EstadoAsignacion.activa),
          isTrue,
        );
      });
    });

    group('activarEmergenciaProvider', () {
      test(
        'llama showImmediateNotification una vez por miembro del equipo',
        () async {
          final miembros = [
            _asignacion('asi_001', _personaMaria),
            _asignacion('asi_002', _personaCarlos),
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
          asignaciones: [_asignacion('asi_001', _personaMaria)],
          scheduler: scheduler,
        );
        addTearDown(container.dispose);

        await container.read(equipoEmergenciaProvider.future);
        final emergencia = await container.read(activarEmergenciaProvider)();

        expect(emergencia.id, isNotEmpty);
        expect(emergencia.persona.id, _personaAlicia.id);
      });
    });

    group('puedeActivarEmergenciaProvider', () {
      test('retorna true con permiso activarEmergencia', () async {
        final scheduler = FakeNotificationScheduler();
        final container = _makeContainer(
          asignaciones: [_asignacion('asi_001', _personaMaria)],
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
          // El helper _makeContainer fija el contexto a Alicia, por lo tanto
          // esContextoPropio = false y sin asignaciones → false.
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
