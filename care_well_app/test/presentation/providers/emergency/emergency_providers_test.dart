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

/// Fake de [AsignacionCuidadoRepository]. La cadena de providers de permisos
/// resuelve la asignación de contexto vía [obtenerAsignacionesPorPersona]; el
/// resto de métodos no se ejercitan en estos tests.
class _FakeAsignacionCuidadoRepository implements AsignacionCuidadoRepository {
  final List<AsignacionCuidado> _asignaciones;

  _FakeAsignacionCuidadoRepository(List<AsignacionCuidado> asignaciones)
    : _asignaciones = List.of(asignaciones);

  @override
  Future<List<AsignacionCuidado>> obtenerAsignacionesPorPersona(
    int personaCuidadaId,
  ) async => _asignaciones
      .where((a) => a.personaCuidada.id == personaCuidadaId)
      .toList();

  @override
  Future<List<AsignacionCuidado>> obtenerAsignacionesUsuarioLogueado() async =>
      // El usuario demo (María, id=1) es el colaborador de sus asignaciones.
      _asignaciones.where((a) => a.colaborador.id == 1).toList();

  @override
  Future<void> crearPersonaCargo({
    required String nombre,
    required String apellido,
    required String documento,
    required DateTime fechaNacimiento,
    String? email,
    String? telefono,
  }) => throw UnimplementedError();

  @override
  Future<Persona> modificarPersonaCargo(int asignacionId, Persona persona) =>
      throw UnimplementedError();

  @override
  Future<void> asignarPersonaEquipoCuidado({
    required int personaCuidadaId,
    required String colaboradorEmail,
    required int rolCuidadoId,
    required List<int> permisosCuidadoIds,
  }) => throw UnimplementedError();

  @override
  Future<void> modificarPermisosAsignacion({
    required int asignacionId,
    required List<PermisoCuidado> permisosSeleccionados,
  }) => throw UnimplementedError();

  @override
  Future<void> eliminarAsignacion(int asignacionId) =>
      throw UnimplementedError();

  @override
  Future<void> activarAsignacion(int asignacionId) =>
      throw UnimplementedError();

  @override
  Future<void> reactivarAsignacion(int asignacionId) =>
      throw UnimplementedError();
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
      personaVisualizacionSeleccionadaProvider.overrideWith(
        (ref) async => _personaAlicia,
      ),
      asignacionCuidadoRepositoryProvider.overrideWithValue(
        _FakeAsignacionCuidadoRepository(asignaciones),
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
              personaVisualizacionSeleccionadaProvider.overrideWith(
                (ref) async => _personaMaria,
              ),
              asignacionCuidadoRepositoryProvider.overrideWithValue(
                _FakeAsignacionCuidadoRepository(const []),
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
