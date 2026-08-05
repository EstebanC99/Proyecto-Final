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
    String? imagen,
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
  _FakeEmergencyRepository({this.historial = const []});

  /// Argumentos con los que se activó cada emergencia.
  final List<({int personaId, String? descripcion})> activadas = [];

  /// Lo que devuelve [getEmergenciasByPersona], en el orden en que se declara.
  final List<Emergencia> historial;

  /// Argumentos con los que se consultó el historial.
  final List<({int personaId, int cantidad})> consultas = [];

  @override
  Future<void> activarEmergencia({
    required int personaId,
    String? descripcion,
  }) async {
    activadas.add((personaId: personaId, descripcion: descripcion));
  }

  @override
  Future<List<Emergencia>> getEmergenciasByPersona(
    int personaId, {
    int cantidad = 20,
  }) async {
    consultas.add((personaId: personaId, cantidad: cantidad));
    return historial;
  }
}

Emergencia _emergencia(int id, DateTime fechaHora) => Emergencia(
  id: id,
  persona: _personaAlicia,
  activador: _personaMaria,
  fechaHora: fechaHora,
);

// ─── Helper ───────────────────────────────────────────────────────────────────

/// [scheduler] solo hace falta en los tests que verifican que el cliente NO
/// emite notificaciones locales; el resto usa uno descartable.
ProviderContainer _makeContainer({
  required List<AsignacionCuidado> asignaciones,
  FakeNotificationScheduler? scheduler,
  _FakeEmergencyRepository? emergencyRepository,
}) {
  final fakeEmergencyRepo = emergencyRepository ?? _FakeEmergencyRepository();
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
      notificationSchedulerProvider.overrideWithValue(
        scheduler ?? FakeNotificationScheduler(),
      ),
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
        final container = _makeContainer(asignaciones: asignaciones);
        addTearDown(container.dispose);

        final equipo = await container.read(equipoEmergenciaProvider.future);
        expect(equipo.length, 2);
        expect(
          equipo.every((a) => a.estado.id == EstadosAsignacionConst.activa),
          isTrue,
        );
      });
    });

    group('historialEmergenciasProvider', () {
      test('es vacío si no hay persona de contexto', () async {
        final repo = _FakeEmergencyRepository();
        final container = ProviderContainer(
          overrides: [
            personaVisualizacionSeleccionadaProvider.overrideWith(
              (ref) async => null,
            ),
            emergencyRepositoryProvider.overrideWithValue(repo),
          ],
        );
        addTearDown(container.dispose);

        final historial = await container.read(
          historialEmergenciasProvider.future,
        );

        expect(historial, isEmpty);
        // Sin persona no hay a quién consultarle: no se llama al backend.
        expect(repo.consultas, isEmpty);
      });

      test('pide la cantidad definida en EmergenciasConst', () async {
        final repo = _FakeEmergencyRepository();
        final container = _makeContainer(
          asignaciones: const [],
          emergencyRepository: repo,
        );
        addTearDown(container.dispose);

        await container.read(historialEmergenciasProvider.future);

        expect(repo.consultas, hasLength(1));
        expect(repo.consultas.single.personaId, _personaAlicia.id);
        expect(
          repo.consultas.single.cantidad,
          EmergenciasConst.cantidadHistorialCorto,
        );
      });

      test(
        'devuelve las emergencias en el orden que llegan del backend',
        () async {
          // El backend ya ordena de la más reciente a la más antigua. Si alguien
          // agrega un sort "para asegurarse", este test lo frena.
          final repo = _FakeEmergencyRepository(
            historial: [
              _emergencia(3, DateTime(2026, 8, 5, 14, 0)),
              _emergencia(1, DateTime(2026, 7, 1, 9, 30)),
              _emergencia(2, DateTime(2026, 8, 1, 20, 15)),
            ],
          );
          final container = _makeContainer(
            asignaciones: const [],
            emergencyRepository: repo,
          );
          addTearDown(container.dispose);

          final historial = await container.read(
            historialEmergenciasProvider.future,
          );

          expect(historial.map((e) => e.id), [3, 1, 2]);
        },
      );
    });

    group('activarEmergenciaProvider', () {
      test('registra la emergencia para la persona de contexto', () async {
        final repo = _FakeEmergencyRepository();
        final container = _makeContainer(
          asignaciones: [_asignacion(401, _personaMaria)],
          emergencyRepository: repo,
        );
        addTearDown(container.dispose);

        await container.read(activarEmergenciaProvider)();

        expect(repo.activadas, hasLength(1));
        expect(repo.activadas.single.personaId, _personaAlicia.id);
        expect(repo.activadas.single.descripcion, isNull);
      });

      test('no notifica localmente a los miembros del equipo', () async {
        // El aviso push lo envía el backend: el cliente no debe emitir
        // notificaciones locales por cada miembro.
        final scheduler = FakeNotificationScheduler();
        final container = _makeContainer(
          asignaciones: [
            _asignacion(401, _personaMaria),
            _asignacion(402, _personaCarlos),
          ],
          scheduler: scheduler,
        );
        addTearDown(container.dispose);

        await container.read(equipoEmergenciaProvider.future);
        await container.read(activarEmergenciaProvider)();

        expect(scheduler.shown, isEmpty);
      });
    });

    group('puedeActivarEmergenciaProvider', () {
      test('retorna true con permiso activarEmergencia', () async {
        final container = _makeContainer(
          asignaciones: [_asignacion(401, _personaMaria)],
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
          final container = _makeContainer(asignaciones: []);
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
