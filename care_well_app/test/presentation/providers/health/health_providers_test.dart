import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/domain/repositories/repositories.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../_fakes/test_fixtures.dart';

// ─── Fixtures ─────────────────────────────────────────────────────────────────

final _personaAlicia = Persona(id: 2, nombre: 'Alicia', apellido: 'Rodríguez');

final _personaMaria = Persona(
  id: 1,
  nombre: 'María',
  apellido: 'García',
  email: 'maria@test.com',
);

final _permisosCompletos = [
  Permiso(
    id: 301,
    codigo: codigoVerFichaSalud,
    descripcion: 'Ver ficha de salud',
  ),
  Permiso(
    id: 304,
    codigo: codigoRegistrarEventosSalud,
    descripcion: 'Registrar eventos de salud',
  ),
  Permiso(
    id: 305,
    codigo: codigoRegistrarHabitos,
    descripcion: 'Registrar hábitos',
  ),
];

AsignacionCuidado _asignacionMaria({
  RolCuidado? rol,
  List<Permiso>? permisos,
}) => AsignacionCuidado(
  id: 401,
  personaCuidada: _personaAlicia,
  personaColaborador: _personaMaria,
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

class _FakeCareTeamRepository implements CareTeamRepository {
  final List<AsignacionCuidado> _asignaciones;

  _FakeCareTeamRepository(this._asignaciones);

  @override
  Future<List<AsignacionCuidado>> getAsignacionesByColaborador(
    int colaboradorId,
  ) async => _asignaciones
      .where((a) => a.personaColaborador.id == colaboradorId)
      .toList();

  @override
  Future<List<AsignacionCuidado>> getAsignacionesByPersonaCuidada(
    int personaCuidadaId,
  ) async => _asignaciones
      .where((a) => a.personaCuidada.id == personaCuidadaId)
      .toList();

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

class _FakeHealthRepository implements HealthRepository {
  final List<EventoDeSalud> _eventos;
  final List<HabitoDeVida> _habitos;
  final List<NotaEvento> _notas;
  final List<EstadoDeAnimo> _estadosAnimo;

  _FakeHealthRepository({
    List<EventoDeSalud>? eventos,
    List<HabitoDeVida>? habitos,
    List<NotaEvento>? notas,
    List<EstadoDeAnimo>? estadosAnimo,
  }) : _eventos = eventos != null ? List.of(eventos) : [],
       _habitos = habitos != null ? List.of(habitos) : [],
       _notas = notas != null ? List.of(notas) : [],
       _estadosAnimo = estadosAnimo != null ? List.of(estadosAnimo) : [];

  @override
  Future<List<EventoDeSalud>> getEventosSaludByPersona(int personaId) async =>
      _eventos.where((e) => e.persona.id == personaId).toList();

  @override
  Future<EventoDeSalud> crearEventoSalud(EventoDeSalud e) async {
    _eventos.add(e);
    return e;
  }

  @override
  Future<EventoDeSalud> actualizarEventoSalud(EventoDeSalud e) async => e;

  @override
  Future<void> eliminarEventoSalud(int id) async {
    _eventos.removeWhere((e) => e.id == id);
    _notas.removeWhere((n) => n.eventoSaludId == id);
  }

  @override
  Future<FichaSalud> getFichaSalud(int personaId) async =>
      throw UnimplementedError();

  @override
  Future<FichaSalud> guardarFichaSalud(FichaSalud ficha) async =>
      throw UnimplementedError();

  @override
  Future<List<HabitoDeVida>> getHabitosByPersona(int personaId) async =>
      _habitos.where((h) => h.persona.id == personaId).toList();

  @override
  Future<HabitoDeVida> crearHabito(HabitoDeVida habito) async {
    _habitos.add(habito);
    return habito;
  }

  @override
  Future<HabitoDeVida> actualizarHabito(HabitoDeVida habito) async {
    final idx = _habitos.indexWhere((h) => h.id == habito.id);
    if (idx >= 0) _habitos[idx] = habito;
    return habito;
  }

  @override
  Future<void> eliminarHabito(int habitoId) async {
    _habitos.removeWhere((h) => h.id == habitoId);
  }

  @override
  Future<List<RecomendacionMedica>> getRecomendacionesByPersona(
    int personaId,
  ) async => [];

  @override
  Future<RecomendacionMedica> crearRecomendacion(RecomendacionMedica r) async =>
      r;

  @override
  Future<RecomendacionMedica> actualizarRecomendacion(
    RecomendacionMedica r,
  ) async => r;

  @override
  Future<void> eliminarRecomendacion(int id) async {}

  @override
  Future<List<NotaEvento>> getNotasByEvento(int eventoId) async =>
      _notas.where((n) => n.eventoSaludId == eventoId).toList();

  @override
  Future<NotaEvento> crearNota(NotaEvento nota) async => nota;

  @override
  Future<List<EstadoDeAnimo>> getEstadosAnimoByPersona(int personaId) async =>
      _estadosAnimo.where((e) => e.persona.id == personaId).toList();

  @override
  Future<EstadoDeAnimo> crearEstadoAnimo(EstadoDeAnimo e) async => e;

  @override
  Future<EstadoDeAnimo> actualizarEstadoAnimo(EstadoDeAnimo e) async => e;

  @override
  Future<void> eliminarEstadoAnimo(int id) async {}
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

/// Construye un container con contexto de persona AJENA (Alicia).
ProviderContainer _makeContainer({
  required List<AsignacionCuidado> asignaciones,
  List<EventoDeSalud>? eventos,
  List<HabitoDeVida>? habitos,
  List<NotaEvento>? notas,
  List<EstadoDeAnimo>? estadosAnimo,
}) {
  return ProviderContainer(
    overrides: [
      authStateProvider.overrideWith(
        (ref) =>
            AuthNotifier(ref.watch(authRepositoryProvider))
              ..state = AsyncValue.data(_usuarioDemoMaria),
      ),
      // Fija el contexto a Alicia (persona ajena) en ambas cadenas de providers.
      careTeamContextPersonaProvider.overrideWith(
        (ref) async => _personaAlicia,
      ),
      healthPersonaContextProvider.overrideWith((ref) async => _personaAlicia),
      careTeamRepositoryProvider.overrideWithValue(
        _FakeCareTeamRepository(asignaciones),
      ),
      healthRepositoryProvider.overrideWithValue(
        _FakeHealthRepository(
          eventos: eventos,
          habitos: habitos,
          notas: notas,
          estadosAnimo: estadosAnimo,
        ),
      ),
    ],
  );
}

/// Construye un container con contexto de persona PROPIA (María).
ProviderContainer _makeContainerContextPropio({
  List<EventoDeSalud>? eventos,
  List<HabitoDeVida>? habitos,
  List<EstadoDeAnimo>? estadosAnimo,
}) {
  return ProviderContainer(
    overrides: [
      authStateProvider.overrideWith(
        (ref) =>
            AuthNotifier(ref.watch(authRepositoryProvider))
              ..state = AsyncValue.data(_usuarioDemoMaria),
      ),
      // Contexto = María (propio usuario).
      careTeamContextPersonaProvider.overrideWith((ref) async => _personaMaria),
      healthPersonaContextProvider.overrideWith((ref) async => _personaMaria),
      careTeamRepositoryProvider.overrideWithValue(_FakeCareTeamRepository([])),
      healthRepositoryProvider.overrideWithValue(
        _FakeHealthRepository(
          eventos: eventos,
          habitos: habitos,
          estadosAnimo: estadosAnimo,
        ),
      ),
    ],
  );
}

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('health_providers', () {
    group('eventosSaludProvider', () {
      test('retorna eventos ordenados descendente por fecha', () async {
        final eventos = [
          EventoDeSalud(
            id: 1101,
            persona: _personaAlicia,
            tipo: tipoEventoSaludCitaMedica,
            fecha: DateTime(2026, 4, 1),
            descripcion: 'Evento antiguo',
          ),
          EventoDeSalud(
            id: 1102,
            persona: _personaAlicia,
            tipo: tipoEventoSaludVacuna,
            fecha: DateTime(2026, 6, 1),
            descripcion: 'Evento reciente',
          ),
        ];
        final container = _makeContainer(
          asignaciones: [_asignacionMaria()],
          eventos: eventos,
        );
        addTearDown(container.dispose);

        final result = await container.read(eventosSaludProvider.future);
        expect(result.first.fecha.isAfter(result.last.fecha), isTrue);
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

    // ─── ultimoEstadoAnimoProvider ────────────────────────────────────────────

    group('ultimoEstadoAnimoProvider', () {
      test(
        'retorna el estado más reciente (primero de la lista descendente)',
        () async {
          final estadoAntiguo = EstadoDeAnimo(
            id: 1201,
            persona: _personaAlicia,
            fecha: DateTime(2026, 5, 1),
            estado: estadoAnimoRegular,
          );
          final estadoReciente = EstadoDeAnimo(
            id: 1202,
            persona: _personaAlicia,
            fecha: DateTime(2026, 6, 1),
            estado: estadoAnimoMuyBien,
          );
          final container = _makeContainer(
            asignaciones: [_asignacionMaria()],
            estadosAnimo: [estadoAntiguo, estadoReciente],
          );
          addTearDown(container.dispose);

          final ultimo = await container.read(ultimoEstadoAnimoProvider.future);
          expect(ultimo, isNotNull);
          expect(ultimo!.estado.id, EstadosAnimoConst.muyBien);
        },
      );

      test('retorna null cuando no hay estados registrados', () async {
        final container = _makeContainer(
          asignaciones: [_asignacionMaria()],
          estadosAnimo: [],
        );
        addTearDown(container.dispose);

        final ultimo = await container.read(ultimoEstadoAnimoProvider.future);
        expect(ultimo, isNull);
      });
    });

    // ─── eliminarHabitoProvider ───────────────────────────────────────────────

    group('eliminarHabitoProvider', () {
      test('quita el hábito de la lista tras eliminar', () async {
        final habito = HabitoDeVida(
          id: 901,
          persona: _personaAlicia,
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
        final evento = EventoDeSalud(
          id: 1101,
          persona: _personaAlicia,
          tipo: tipoEventoSaludCitaMedica,
          fecha: DateTime(2026, 5, 10),
          descripcion: 'Cita médica',
        );
        final nota = NotaEvento(
          id: 1301,
          eventoSaludId: 1101,
          autor: _personaMaria,
          fechaHora: DateTime(2026, 5, 10, 10),
          contenido: 'Nota de prueba',
        );
        final container = _makeContainer(
          asignaciones: [_asignacionMaria()],
          eventos: [evento],
          notas: [nota],
        );
        addTearDown(container.dispose);

        // Precondición: hay un evento.
        final antes = await container.read(eventosSaludProvider.future);
        expect(antes, hasLength(1));

        // Ejecutar eliminación.
        await container.read(eliminarEventoSaludProvider)(eventoId: 1101);

        // El provider fue invalidado; al releer debe estar vacío.
        final despues = await container.read(eventosSaludProvider.future);
        expect(despues, isEmpty);
      });
    });
  });
}
