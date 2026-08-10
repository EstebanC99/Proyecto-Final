import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/domain/repositories/repositories.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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
  email: 'maria@test.com',
);

final _permisosCompletos = [
  PermisoCuidado(
    id: PermisosCuidadoConst.verFichaSalud,
    descripcion: 'Ver ficha de salud',
  ),
  PermisoCuidado(
    id: PermisosCuidadoConst.registrarEventosSalud,
    descripcion: 'Registrar eventos de salud',
  ),
  PermisoCuidado(
    id: PermisosCuidadoConst.registrarHabitos,
    descripcion: 'Registrar hábitos',
  ),
];

AsignacionCuidado _asignacionMaria({
  RolCuidado? rol,
  List<PermisoCuidado>? permisos,
}) => AsignacionCuidado(
  id: 401,
  personaCuidada: _personaAlicia,
  colaborador: _personaMaria,
  rol: rol ?? rolCuidadoResponsable,
  estado: estadoAsignacionActiva,
  fechaAlta: DateTime(2024, 1, 8),
  permisos: permisos ?? _permisosCompletos,
);

final _usuarioDemoMaria = Usuario(
  id: 101,
  persona: _personaMaria,
  contrasena: 'hash123',
  estado: estadoUsuarioActivo,
);

// ─── Fake repositories ────────────────────────────────────────────────────────

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

class _FakeEstadoAnimoRepository implements EstadoAnimoRepository {
  final List<PersonaEstadoAnimo> _estadosAnimo;

  _FakeEstadoAnimoRepository({List<PersonaEstadoAnimo>? estadosAnimo})
    : _estadosAnimo = estadosAnimo != null ? List.of(estadosAnimo) : [];

  @override
  Future<PersonaEstadoAnimo?> obtenerAnimoHoy(Persona persona) async =>
      _estadosAnimo
          .where((e) => e.persona.id == persona.id)
          .fold<PersonaEstadoAnimo?>(
            null,
            (mas, e) => mas == null || e.fecha.isAfter(mas.fecha) ? e : mas,
          );

  @override
  Future<List<PersonaEstadoAnimo>> obtenerPorFechas({
    required Persona persona,
    required DateTime desde,
    required DateTime hasta,
  }) async => _estadosAnimo.where((e) => e.persona.id == persona.id).toList();

  @override
  Future<void> registrar({
    required int personaId,
    required int estadoAnimoId,
    String? observaciones,
  }) async {}
}

class _FakeHabitoVidaRepository implements HabitoVidaRepository {
  final List<HabitoVida> _habitos;

  _FakeHabitoVidaRepository({List<HabitoVida>? habitos})
    : _habitos = habitos != null ? List.of(habitos) : [];

  @override
  Future<List<HabitoVida>> getHabitosByPersona(int personaId) async =>
      _habitos.where((h) => h.persona.id == personaId).toList();

  @override
  Future<void> crearHabito({
    required int personaId,
    required int tipoId,
    required String descripcion,
  }) async {}

  @override
  Future<void> modificarHabito({
    required int habitoId,
    required int tipoId,
    required String descripcion,
  }) async {}

  @override
  Future<void> eliminarHabito(int habitoId) async {
    _habitos.removeWhere((h) => h.id == habitoId);
  }

  @override
  Future<void> crearRealizacion({
    required int habitoId,
    String? comentarios,
  }) async {}

  @override
  Future<void> modificarRealizacion({
    required int habitoId,
    required int realizacionId,
    String? comentarios,
  }) async {}

  @override
  Future<void> eliminarRealizacion({
    required int habitoId,
    required int realizacionId,
  }) async {}
}

class _FakeEventoSaludRepository implements EventoSaludRepository {
  final List<EventoSalud> _eventos;

  /// Rango de la última consulta, para verificar las ventanas que arman los
  /// providers.
  DateTime? ultimoDesde;
  DateTime? ultimoHasta;
  int consultasCount = 0;

  _FakeEventoSaludRepository({List<EventoSalud>? eventos})
    : _eventos = eventos != null ? List.of(eventos) : [];

  // Filtra por persona y por el rango [desde, hasta) —`hasta` exclusivo, igual
  // que el contrato del backend.
  @override
  Future<List<EventoSalud>> getEventosSaludDelMes({
    required int personaId,
    required DateTime desde,
    required DateTime hasta,
  }) async {
    consultasCount++;
    ultimoDesde = desde;
    ultimoHasta = hasta;
    return _eventos
        .where(
          (e) =>
              e.persona.id == personaId &&
              !e.fechaHora.isBefore(desde) &&
              e.fechaHora.isBefore(hasta),
        )
        .toList();
  }

  @override
  Future<void> crearEventoSalud({
    required int personaId,
    required int tipoId,
    required DateTime fechaHora,
    required String descripcion,
  }) async {}

  @override
  Future<void> eliminarEventoSalud(int eventoId) async {
    _eventos.removeWhere((e) => e.id == eventoId);
  }

  @override
  Future<void> agregarNota({
    required int eventoSaludId,
    required String contenido,
  }) async {}

  @override
  Future<void> modificarNota({
    required int eventoSaludId,
    required int notaId,
    required String contenido,
  }) async {}

  @override
  Future<void> eliminarNota({
    required int eventoSaludId,
    required int notaId,
  }) async {}
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

/// Construye un container con contexto de persona AJENA (Alicia).
ProviderContainer _makeContainer({
  required List<AsignacionCuidado> asignaciones,
  List<EventoSalud>? eventos,
  List<HabitoVida>? habitos,
  List<PersonaEstadoAnimo>? estadosAnimo,
  _FakeEventoSaludRepository? eventoSaludRepo,
  bool sinPersonaContexto = false,
}) {
  return ProviderContainer(
    overrides: [
      authStateProvider.overrideWith(
        (ref) =>
            AuthNotifier(ref.watch(authRepositoryProvider))
              ..state = AsyncValue.data(_usuarioDemoMaria),
      ),
      // Fija el contexto a Alicia (persona ajena) en ambas cadenas de providers.
      personaVisualizacionSeleccionadaProvider.overrideWith(
        (ref) async => sinPersonaContexto ? null : _personaAlicia,
      ),
      asignacionCuidadoRepositoryProvider.overrideWithValue(
        _FakeAsignacionCuidadoRepository(asignaciones),
      ),
      estadoAnimoRepositoryProvider.overrideWithValue(
        _FakeEstadoAnimoRepository(estadosAnimo: estadosAnimo),
      ),
      habitoVidaRepositoryProvider.overrideWithValue(
        _FakeHabitoVidaRepository(habitos: habitos),
      ),
      eventoSaludRepositoryProvider.overrideWithValue(
        eventoSaludRepo ?? _FakeEventoSaludRepository(eventos: eventos),
      ),
    ],
  );
}

/// Construye un container con contexto de persona PROPIA (María).
ProviderContainer _makeContainerContextPropio({
  List<EventoSalud>? eventos,
  List<HabitoVida>? habitos,
  List<PersonaEstadoAnimo>? estadosAnimo,
}) {
  return ProviderContainer(
    overrides: [
      authStateProvider.overrideWith(
        (ref) =>
            AuthNotifier(ref.watch(authRepositoryProvider))
              ..state = AsyncValue.data(_usuarioDemoMaria),
      ),
      // Contexto = María (propio usuario).
      personaVisualizacionSeleccionadaProvider.overrideWith(
        (ref) async => _personaMaria,
      ),
      asignacionCuidadoRepositoryProvider.overrideWithValue(
        _FakeAsignacionCuidadoRepository(const []),
      ),
      estadoAnimoRepositoryProvider.overrideWithValue(
        _FakeEstadoAnimoRepository(estadosAnimo: estadosAnimo),
      ),
      habitoVidaRepositoryProvider.overrideWithValue(
        _FakeHabitoVidaRepository(habitos: habitos),
      ),
      eventoSaludRepositoryProvider.overrideWithValue(
        _FakeEventoSaludRepository(eventos: eventos),
      ),
    ],
  );
}

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('health_providers', () {
    group('eventosSaludDeSemanaProvider', () {
      test('retorna eventos ordenados ascendente por fecha', () async {
        final eventos = [
          EventoSalud(
            id: 1102,
            persona: refPersonaAlicia,
            tipo: tipoEventoSaludVacuna,
            fechaHora: DateTime(2026, 6, 3, 18),
            descripcion: 'Evento reciente',
          ),
          EventoSalud(
            id: 1101,
            persona: refPersonaAlicia,
            tipo: tipoEventoSaludCitaMedica,
            fechaHora: DateTime(2026, 6, 1, 9),
            descripcion: 'Evento antiguo',
          ),
        ];
        final container = _makeContainer(
          asignaciones: [_asignacionMaria()],
          eventos: eventos,
        );
        addTearDown(container.dispose);

        // Semana del lunes 01/06/2026.
        container.read(semanaEventosSaludProvider.notifier).state = DateTime(
          2026,
          6,
          1,
        );

        final result = await container.read(
          eventosSaludDeSemanaProvider.future,
        );
        expect(result, hasLength(2));
        expect(result.first.fechaHora.isBefore(result.last.fechaHora), isTrue);
      });

      test('consulta la ventana de lunes a domingo de la semana', () async {
        final repo = _FakeEventoSaludRepository();
        final container = _makeContainer(
          asignaciones: [_asignacionMaria()],
          eventoSaludRepo: repo,
        );
        addTearDown(container.dispose);

        container.read(semanaEventosSaludProvider.notifier).state = DateTime(
          2026,
          6,
          1,
        );
        await container.read(eventosSaludDeSemanaProvider.future);

        expect(repo.ultimoDesde, DateTime(2026, 6, 1));
        expect(repo.ultimoHasta, DateTime(2026, 6, 8));
      });

      test('excluye los eventos fuera de la semana visible', () async {
        final eventos = [
          EventoSalud(
            id: 1101,
            persona: refPersonaAlicia,
            tipo: tipoEventoSaludCitaMedica,
            fechaHora: DateTime(2026, 6, 3, 9),
            descripcion: 'Dentro de la semana',
          ),
          EventoSalud(
            id: 1102,
            persona: refPersonaAlicia,
            tipo: tipoEventoSaludVacuna,
            fechaHora: DateTime(2026, 6, 9, 9),
            descripcion: 'Semana siguiente',
          ),
        ];
        final container = _makeContainer(
          asignaciones: [_asignacionMaria()],
          eventos: eventos,
        );
        addTearDown(container.dispose);

        container.read(semanaEventosSaludProvider.notifier).state = DateTime(
          2026,
          6,
          1,
        );

        final result = await container.read(
          eventosSaludDeSemanaProvider.future,
        );
        expect(result.map((e) => e.id), [1101]);
      });
    });

    group('eventoSaludAnteriorProvider', () {
      /// Evento de Alicia en [fechaHora].
      EventoSalud evento(int id, DateTime fechaHora) => EventoSalud(
        id: id,
        persona: refPersonaAlicia,
        tipo: tipoEventoSaludCitaMedica,
        fechaHora: fechaHora,
        descripcion: 'Evento $id',
      );

      test('consulta los 90 días previos al día seleccionado', () async {
        final repo = _FakeEventoSaludRepository();
        final container = _makeContainer(
          asignaciones: [_asignacionMaria()],
          eventoSaludRepo: repo,
        );
        addTearDown(container.dispose);

        container.read(diaEventosSaludSeleccionadoProvider.notifier).state =
            DateTime(2026, 6, 10);
        await container.read(eventoSaludAnteriorProvider.future);

        expect(repo.ultimoHasta, DateTime(2026, 6, 10));
        expect(
          repo.ultimoDesde,
          DateTime(2026, 6, 10).subtract(const Duration(days: 90)),
        );
      });

      test('devuelve el evento más reciente anterior al día', () async {
        final container = _makeContainer(
          asignaciones: [_asignacionMaria()],
          eventos: [
            evento(1101, DateTime(2026, 5, 20, 10)),
            evento(1102, DateTime(2026, 6, 8, 16)),
            evento(1103, DateTime(2026, 4, 2, 8)),
          ],
        );
        addTearDown(container.dispose);

        container.read(diaEventosSaludSeleccionadoProvider.notifier).state =
            DateTime(2026, 6, 10);

        final anterior = await container.read(
          eventoSaludAnteriorProvider.future,
        );
        expect(anterior?.id, 1102);
      });

      test('no considera los eventos del día seleccionado', () async {
        final container = _makeContainer(
          asignaciones: [_asignacionMaria()],
          eventos: [
            evento(1101, DateTime(2026, 6, 10)),
            evento(1102, DateTime(2026, 6, 10, 23, 59)),
          ],
        );
        addTearDown(container.dispose);

        container.read(diaEventosSaludSeleccionadoProvider.notifier).state =
            DateTime(2026, 6, 10);

        expect(
          await container.read(eventoSaludAnteriorProvider.future),
          isNull,
        );
      });

      test(
        'devuelve null si no hay eventos en la ventana de 90 días',
        () async {
          final container = _makeContainer(
            asignaciones: [_asignacionMaria()],
            eventos: [evento(1101, DateTime(2026, 1, 5))],
          );
          addTearDown(container.dispose);

          container.read(diaEventosSaludSeleccionadoProvider.notifier).state =
              DateTime(2026, 6, 10);

          expect(
            await container.read(eventoSaludAnteriorProvider.future),
            isNull,
          );
        },
      );

      test('devuelve null y no consulta cuando no hay persona', () async {
        final repo = _FakeEventoSaludRepository(
          eventos: [evento(1101, DateTime(2026, 6, 8))],
        );
        final container = _makeContainer(
          asignaciones: [_asignacionMaria()],
          eventoSaludRepo: repo,
          sinPersonaContexto: true,
        );
        addTearDown(container.dispose);

        expect(
          await container.read(eventoSaludAnteriorProvider.future),
          isNull,
        );
        expect(repo.consultasCount, 0);
      });
    });

    group('puedeVerSaludProvider', () {
      test('retorna true cuando la asignación tiene el permiso', () async {
        final container = _makeContainer(asignaciones: [_asignacionMaria()]);
        addTearDown(container.dispose);

        final puede = await container.read(puedeVerSaludProvider.future);
        expect(puede, isTrue);
      });

      test('retorna false cuando la asignación no tiene el permiso', () async {
        final container = _makeContainer(
          asignaciones: [_asignacionMaria(permisos: [])],
        );
        addTearDown(container.dispose);

        final puede = await container.read(puedeVerSaludProvider.future);
        expect(puede, isFalse);
      });

      test('retorna false cuando no hay asignación (contexto ajeno)', () async {
        final container = _makeContainer(asignaciones: []);
        addTearDown(container.dispose);

        final puede = await container.read(puedeVerSaludProvider.future);
        expect(puede, isFalse);
      });

      test(
        'retorna true cuando el contexto es el propio usuario sin asignaciones',
        () async {
          final container = _makeContainerContextPropio();
          addTearDown(container.dispose);

          final puede = await container.read(puedeVerSaludProvider.future);
          expect(puede, isTrue);
        },
      );
    });

    group('puedeRegistrarEventosSaludProvider', () {
      test('retorna true con permiso registrarEventosSalud', () async {
        final container = _makeContainer(asignaciones: [_asignacionMaria()]);
        addTearDown(container.dispose);

        final puede = await container.read(
          puedeRegistrarEventosSaludProvider.future,
        );
        expect(puede, isTrue);
      });

      test(
        'retorna true cuando el contexto es el propio usuario sin asignaciones',
        () async {
          final container = _makeContainerContextPropio();
          addTearDown(container.dispose);

          final puede = await container.read(
            puedeRegistrarEventosSaludProvider.future,
          );
          expect(puede, isTrue);
        },
      );
    });

    group('puedeRegistrarHabitosProvider', () {
      test('retorna true con permiso registrarHabitos', () async {
        final container = _makeContainer(asignaciones: [_asignacionMaria()]);
        addTearDown(container.dispose);

        final puede = await container.read(
          puedeRegistrarHabitosProvider.future,
        );
        expect(puede, isTrue);
      });

      test(
        'retorna true cuando el contexto es el propio usuario sin asignaciones',
        () async {
          final container = _makeContainerContextPropio();
          addTearDown(container.dispose);

          final puede = await container.read(
            puedeRegistrarHabitosProvider.future,
          );
          expect(puede, isTrue);
        },
      );
    });

    // ─── animoHoyProvider ─────────────────────────────────────────────────────

    group('animoHoyProvider', () {
      test('retorna el estado de ánimo cuando hay registro hoy', () async {
        final animoHoy = PersonaEstadoAnimo(
          id: 1202,
          persona: _personaAlicia,
          fecha: DateTime.now(),
          estado: estadoAnimoMuyBien,
        );
        final container = _makeContainer(
          asignaciones: [_asignacionMaria()],
          estadosAnimo: [animoHoy],
        );
        addTearDown(container.dispose);

        final hoy = await container.read(animoHoyProvider.future);
        expect(hoy, isNotNull);
        expect(hoy!.estado.id, EstadosAnimoConst.muyBien);
      });

      test('retorna null cuando no hay ánimo registrado hoy', () async {
        final container = _makeContainer(
          asignaciones: [_asignacionMaria()],
          estadosAnimo: [],
        );
        addTearDown(container.dispose);

        final hoy = await container.read(animoHoyProvider.future);
        expect(hoy, isNull);
      });
    });

    // ─── eliminarHabitoProvider ───────────────────────────────────────────────

    group('eliminarHabitoProvider', () {
      test('quita el hábito de la lista tras eliminar', () async {
        final habito = HabitoVida(
          id: 901,
          persona: EntidadBasica(
            id: _personaAlicia.id,
            descripcion: 'Alicia Rodríguez',
          ),
          tipo: tipoHabitoAlimentacion,
          descripcion: 'Desayuno saludable',
        );
        final container = _makeContainer(
          asignaciones: [_asignacionMaria()],
          habitos: [habito],
        );
        addTearDown(container.dispose);

        // Precondición: hay un hábito.
        final antes = await container.read(habitosProvider.future);
        expect(antes, hasLength(1));

        // Ejecutar eliminación.
        await container.read(eliminarHabitoProvider)(habitoId: 901);

        // El provider fue invalidado; al releer debe estar vacío.
        final despues = await container.read(habitosProvider.future);
        expect(despues, isEmpty);
      });
    });

    // ─── eliminarEventoSaludProvider ──────────────────────────────────────────

    group('eliminarEventoSaludProvider', () {
      test('quita el evento de la lista tras eliminar', () async {
        final evento = EventoSalud(
          id: 1101,
          persona: refPersonaAlicia,
          tipo: tipoEventoSaludCitaMedica,
          fechaHora: DateTime(2026, 5, 10),
          descripcion: 'Cita médica',
          notas: [
            NotaEventoSalud(
              id: 1301,
              eventoSaludId: 1101,
              autor: refPersonaMaria,
              fechaHora: DateTime(2026, 5, 10, 10),
              contenido: 'Nota de prueba',
            ),
          ],
        );
        final container = _makeContainer(
          asignaciones: [_asignacionMaria()],
          eventos: [evento],
        );
        addTearDown(container.dispose);

        // Semana del lunes 04/05/2026, que contiene al evento.
        container.read(semanaEventosSaludProvider.notifier).state = DateTime(
          2026,
          5,
          4,
        );

        // Precondición: hay un evento.
        final antes = await container.read(eventosSaludDeSemanaProvider.future);
        expect(antes, hasLength(1));

        // Ejecutar eliminación.
        await container.read(eliminarEventoSaludProvider)(eventoId: 1101);

        // El provider fue invalidado; al releer debe estar vacío.
        final despues = await container.read(
          eventosSaludDeSemanaProvider.future,
        );
        expect(despues, isEmpty);
      });
    });
  });
}
