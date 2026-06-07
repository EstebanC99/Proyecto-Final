import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/domain/repositories/repositories.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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

final _permisosCompletos = [
  const Permiso(
    id: 'prm_001',
    codigo: CodigoPermiso.verFichaSalud,
    descripcion: 'Ver ficha de salud',
  ),
  const Permiso(
    id: 'prm_004',
    codigo: CodigoPermiso.registrarEventosSalud,
    descripcion: 'Registrar eventos de salud',
  ),
  const Permiso(
    id: 'prm_005',
    codigo: CodigoPermiso.registrarHabitos,
    descripcion: 'Registrar hábitos',
  ),
];

final _rolResponsable = Rol(
  id: 'rol_001',
  nombre: RolCuidado.responsable,
  permisos: _permisosCompletos,
);

final _rolCuidadorSinPermisos = Rol(
  id: 'rol_002',
  nombre: RolCuidado.cuidador,
  permisos: [],
);

AsignacionCuidado _asignacionMaria({Rol? rol}) => AsignacionCuidado(
  id: 'asi_003',
  personaCuidada: _personaAlicia,
  personaColaborador: _personaMaria,
  rol: rol ?? _rolResponsable,
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
  Future<List<EventoDeSalud>> getEventosSaludByPersona(
    String personaId,
  ) async => _eventos.where((e) => e.persona.id == personaId).toList();

  @override
  Future<EventoDeSalud> crearEventoSalud(EventoDeSalud e) async {
    _eventos.add(e);
    return e;
  }

  @override
  Future<EventoDeSalud> actualizarEventoSalud(EventoDeSalud e) async => e;

  @override
  Future<void> eliminarEventoSalud(String id) async {
    _eventos.removeWhere((e) => e.id == id);
    _notas.removeWhere((n) => n.eventoSaludId == id);
  }

  @override
  Future<FichaSalud> getFichaSalud(String personaId) async =>
      throw UnimplementedError();

  @override
  Future<FichaSalud> guardarFichaSalud(FichaSalud ficha) async =>
      throw UnimplementedError();

  @override
  Future<List<HabitoDeVida>> getHabitosByPersona(String personaId) async =>
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
  Future<void> eliminarHabito(String habitoId) async {
    _habitos.removeWhere((h) => h.id == habitoId);
  }

  @override
  Future<List<RecomendacionMedica>> getRecomendacionesByPersona(
    String personaId,
  ) async => [];

  @override
  Future<RecomendacionMedica> crearRecomendacion(RecomendacionMedica r) async =>
      r;

  @override
  Future<RecomendacionMedica> actualizarRecomendacion(
    RecomendacionMedica r,
  ) async => r;

  @override
  Future<void> eliminarRecomendacion(String id) async {}

  @override
  Future<List<NotaEvento>> getNotasByEvento(String eventoId) async =>
      _notas.where((n) => n.eventoSaludId == eventoId).toList();

  @override
  Future<NotaEvento> crearNota(NotaEvento nota) async => nota;

  @override
  Future<List<EstadoDeAnimo>> getEstadosAnimoByPersona(
    String personaId,
  ) async => _estadosAnimo.where((e) => e.persona.id == personaId).toList();

  @override
  Future<EstadoDeAnimo> crearEstadoAnimo(EstadoDeAnimo e) async => e;

  @override
  Future<EstadoDeAnimo> actualizarEstadoAnimo(EstadoDeAnimo e) async => e;

  @override
  Future<void> eliminarEstadoAnimo(String id) async {}
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

/// Construye un container con contexto de persona AJENA (Alicia).
///
/// Sobreescribe tanto [healthPersonaContextProvider] como
/// [careTeamContextPersonaProvider] a Alicia, asegurando que
/// [esContextoPropioProvider] retorne `false` y los permisos RBAC sean evaluados.
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
///
/// [esContextoPropioProvider] retorna `true`, por lo que los permisos deben
/// concederse sin necesidad de asignación.
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
      careTeamRepositoryProvider.overrideWithValue(
        _FakeCareTeamRepository(
          [],
        ), // sin asignaciones — no deben ser necesarias
      ),
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
            id: 'e1',
            persona: _personaAlicia,
            tipo: TipoEventoSalud.citaMedica,
            fecha: DateTime(2026, 4, 1),
            descripcion: 'Evento antiguo',
          ),
          EventoDeSalud(
            id: 'e2',
            persona: _personaAlicia,
            tipo: TipoEventoSalud.vacuna,
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
          asignaciones: [_asignacionMaria(rol: _rolCuidadorSinPermisos)],
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
            id: 'ani_001',
            persona: _personaAlicia,
            fecha: DateTime(2026, 5, 1),
            estado: EstadoAnimoEnum.regular,
          );
          final estadoReciente = EstadoDeAnimo(
            id: 'ani_002',
            persona: _personaAlicia,
            fecha: DateTime(2026, 6, 1),
            estado: EstadoAnimoEnum.muyBien,
          );
          // El provider ordena descendente, así el primero es el más reciente.
          final container = _makeContainer(
            asignaciones: [_asignacionMaria()],
            estadosAnimo: [estadoAntiguo, estadoReciente],
          );
          addTearDown(container.dispose);

          final ultimo = await container.read(ultimoEstadoAnimoProvider.future);
          expect(ultimo, isNotNull);
          expect(ultimo!.estado, EstadoAnimoEnum.muyBien);
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
          id: 'hab_001',
          persona: _personaAlicia,
          tipo: TipoHabito.alimentacion,
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
        await container.read(eliminarHabitoProvider)(habitoId: 'hab_001');

        // El provider fue invalidado; al releer debe estar vacío.
        final despues = await container.read(habitosProvider.future);
        expect(despues, isEmpty);
      });
    });

    // ─── eliminarEventoSaludProvider ──────────────────────────────────────────

    group('eliminarEventoSaludProvider', () {
      test('quita el evento de la lista tras eliminar', () async {
        final evento = EventoDeSalud(
          id: 'esa_001',
          persona: _personaAlicia,
          tipo: TipoEventoSalud.citaMedica,
          fecha: DateTime(2026, 5, 10),
          descripcion: 'Cita médica',
        );
        final nota = NotaEvento(
          id: 'not_001',
          eventoSaludId: 'esa_001',
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
        await container.read(eliminarEventoSaludProvider)(eventoId: 'esa_001');

        // El provider fue invalidado; al releer debe estar vacío.
        final despues = await container.read(eventosSaludProvider.future);
        expect(despues, isEmpty);
      });
    });
  });
}
