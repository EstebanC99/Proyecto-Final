import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/entities.dart';
import '../auth/auth_providers.dart';
import '../care_team/care_team_providers.dart';
import '../di_providers.dart';

// ─── Contexto de persona para Mi salud ───────────────────────────────────────

/// Persona de contexto para el módulo salud (reutiliza [careTeamContextPersonaProvider]).
final healthPersonaContextProvider = FutureProvider<Persona?>(
  (ref) => ref.watch(careTeamContextPersonaProvider.future),
);

// ─── Permisos RBAC ────────────────────────────────────────────────────────────

/// Helper interno: obtiene la asignación activa del usuario para la persona de contexto.
Future<AsignacionCuidado?> _asignacionActivaDelUsuario(Ref ref) async {
  final usuario = ref.watch(authStateProvider).valueOrNull;
  if (usuario == null) return null;

  final persona = await ref.watch(healthPersonaContextProvider.future);
  if (persona == null) return null;

  final repo = ref.watch(careTeamRepositoryProvider);
  final asignaciones = await repo.getAsignacionesByColaborador(
    usuario.persona.id,
  );

  return asignaciones
      .where(
        (a) =>
            a.personaCuidada.id == persona.id &&
            a.estado == EstadoAsignacion.activa,
      )
      .firstOrNull;
}

/// Indica si el usuario puede ver la ficha de salud.
///
/// Retorna `true` automáticamente cuando el usuario visualiza su propio contexto.
final puedeVerSaludProvider = FutureProvider<bool>((ref) async {
  final esPropio = await ref.watch(esContextoPropioProvider.future);
  if (esPropio) return true;

  final asignacion = await _asignacionActivaDelUsuario(ref);
  if (asignacion == null) return false;
  return asignacion.permisos.any(
    (p) => p.codigo == CodigoPermiso.verFichaSalud,
  );
});

/// Indica si el usuario puede registrar eventos de salud.
///
/// Retorna `true` automáticamente cuando el usuario visualiza su propio contexto.
final puedeRegistrarEventosSaludProvider = FutureProvider<bool>((ref) async {
  final esPropio = await ref.watch(esContextoPropioProvider.future);
  if (esPropio) return true;

  final asignacion = await _asignacionActivaDelUsuario(ref);
  if (asignacion == null) return false;
  return asignacion.permisos.any(
    (p) => p.codigo == CodigoPermiso.registrarEventosSalud,
  );
});

/// Indica si el usuario puede registrar hábitos de vida.
///
/// Retorna `true` automáticamente cuando el usuario visualiza su propio contexto.
final puedeRegistrarHabitosProvider = FutureProvider<bool>((ref) async {
  final esPropio = await ref.watch(esContextoPropioProvider.future);
  if (esPropio) return true;

  final asignacion = await _asignacionActivaDelUsuario(ref);
  if (asignacion == null) return false;
  return asignacion.permisos.any(
    (p) => p.codigo == CodigoPermiso.registrarHabitos,
  );
});

// ─── Hábitos de vida ──────────────────────────────────────────────────────────

/// Lista de hábitos de la persona de contexto.
final habitosProvider = FutureProvider<List<HabitoDeVida>>((ref) async {
  final persona = await ref.watch(healthPersonaContextProvider.future);
  if (persona == null) return [];
  return ref.watch(healthRepositoryProvider).getHabitosByPersona(persona.id);
});

// ─── Recomendaciones médicas ─────────────────────────────────────────────────

/// Lista de recomendaciones de la persona de contexto.
final recomendacionesProvider = FutureProvider<List<RecomendacionMedica>>((
  ref,
) async {
  final persona = await ref.watch(healthPersonaContextProvider.future);
  if (persona == null) return [];
  return ref
      .watch(healthRepositoryProvider)
      .getRecomendacionesByPersona(persona.id);
});

// ─── Eventos de salud ─────────────────────────────────────────────────────────

/// Lista de eventos de salud de la persona de contexto, ordenada descendente por fecha.
final eventosSaludProvider = FutureProvider<List<EventoDeSalud>>((ref) async {
  final persona = await ref.watch(healthPersonaContextProvider.future);
  if (persona == null) return [];
  final eventos = await ref
      .watch(healthRepositoryProvider)
      .getEventosSaludByPersona(persona.id);
  return eventos..sort((a, b) => b.fecha.compareTo(a.fecha));
});

/// Evento de salud individual por ID. Busca en la lista ya cargada.
///
/// Retorna `null` si no existe.
final eventoSaludByIdProvider = FutureProvider.family<EventoDeSalud?, String>((
  ref,
  id,
) async {
  final eventos = await ref.watch(eventosSaludProvider.future);
  return eventos.where((e) => e.id == id).firstOrNull;
});

// ─── Notas de eventos de salud ───────────────────────────────────────────────

/// Notas del evento con [eventoId], ordenadas cronológicamente ascendente.
final notasByEventoProvider = FutureProvider.family<List<NotaEvento>, String>((
  ref,
  eventoId,
) async {
  final notas = await ref
      .watch(healthRepositoryProvider)
      .getNotasByEvento(eventoId);
  return notas..sort((a, b) => a.fechaHora.compareTo(b.fechaHora));
});

// ─── Estados de ánimo ─────────────────────────────────────────────────────────

/// Lista de estados de ánimo de la persona de contexto, ordenada descendente.
final estadosAnimoProvider = FutureProvider<List<EstadoDeAnimo>>((ref) async {
  final persona = await ref.watch(healthPersonaContextProvider.future);
  if (persona == null) return [];
  final estados = await ref
      .watch(healthRepositoryProvider)
      .getEstadosAnimoByPersona(persona.id);
  return estados..sort((a, b) => b.fecha.compareTo(a.fecha));
});

// ─── Acciones mutadoras ───────────────────────────────────────────────────────

/// Hábito de vida individual por ID. Busca en la lista ya cargada.
///
/// Retorna `null` si no existe.
final habitoByIdProvider = FutureProvider.family<HabitoDeVida?, String>((
  ref,
  id,
) async {
  final habitos = await ref.watch(habitosProvider.future);
  return habitos.where((h) => h.id == id).firstOrNull;
});

/// Actualiza un hábito de vida existente e invalida la lista.
final actualizarHabitoProvider =
    Provider<Future<HabitoDeVida> Function({required HabitoDeVida habito})>((
      ref,
    ) {
      return ({required habito}) async {
        final repo = ref.read(healthRepositoryProvider);
        final actualizado = await repo.actualizarHabito(habito);
        ref.invalidate(habitosProvider);
        ref.invalidate(habitoByIdProvider(habito.id));
        return actualizado;
      };
    });

/// Elimina un hábito de vida e invalida la lista.
final eliminarHabitoProvider =
    Provider<Future<void> Function({required String habitoId})>((ref) {
      return ({required habitoId}) async {
        final repo = ref.read(healthRepositoryProvider);
        await repo.eliminarHabito(habitoId);
        ref.invalidate(habitosProvider);
      };
    });

/// Crea un hábito de vida para la persona de contexto.
final crearHabitoProvider =
    Provider<
      Future<HabitoDeVida> Function({
        required TipoHabito tipo,
        required String descripcion,
      })
    >((ref) {
      return ({required tipo, required descripcion}) async {
        final persona = await ref.read(healthPersonaContextProvider.future);
        if (persona == null) throw Exception('Sin persona de contexto');

        final repo = ref.read(healthRepositoryProvider);
        final habito = HabitoDeVida(
          id: '',
          persona: persona,
          tipo: tipo,
          descripcion: descripcion,
        );
        final creado = await repo.crearHabito(habito);
        ref.invalidate(habitosProvider);
        return creado;
      };
    });

/// Crea un evento de salud para la persona de contexto.
final crearEventoSaludProvider =
    Provider<
      Future<EventoDeSalud> Function({
        required TipoEventoSalud tipo,
        required String descripcion,
        required DateTime fecha,
      })
    >((ref) {
      return ({required tipo, required descripcion, required fecha}) async {
        final persona = await ref.read(healthPersonaContextProvider.future);
        if (persona == null) throw Exception('Sin persona de contexto');

        final repo = ref.read(healthRepositoryProvider);
        final evento = EventoDeSalud(
          id: '',
          persona: persona,
          tipo: tipo,
          fecha: fecha,
          descripcion: descripcion,
        );
        final creado = await repo.crearEventoSalud(evento);
        ref.invalidate(eventosSaludProvider);
        return creado;
      };
    });

/// Crea una nota en un evento de salud.
final crearNotaEventoProvider =
    Provider<
      Future<NotaEvento> Function({
        required String eventoSaludId,
        required String contenido,
      })
    >((ref) {
      return ({required eventoSaludId, required contenido}) async {
        final usuario = ref.read(authStateProvider).valueOrNull;
        if (usuario == null) throw Exception('Sin sesión');

        final repo = ref.read(healthRepositoryProvider);
        final nota = NotaEvento(
          id: '',
          eventoSaludId: eventoSaludId,
          autor: usuario.persona,
          fechaHora: DateTime.now(),
          contenido: contenido,
        );
        final creada = await repo.crearNota(nota);
        ref.invalidate(notasByEventoProvider(eventoSaludId));
        return creada;
      };
    });

/// Elimina un evento de salud e invalida la lista.
final eliminarEventoSaludProvider =
    Provider<Future<void> Function({required String eventoId})>((ref) {
      return ({required eventoId}) async {
        final repo = ref.read(healthRepositoryProvider);
        await repo.eliminarEventoSalud(eventoId);
        ref.invalidate(eventosSaludProvider);
      };
    });

/// Último estado de ánimo registrado para la persona de contexto.
///
/// La lista [estadosAnimoProvider] ya viene ordenada descendente, por lo que
/// el primero es el más reciente. Retorna `null` si no hay registros.
final ultimoEstadoAnimoProvider = FutureProvider<EstadoDeAnimo?>((ref) async {
  final estados = await ref.watch(estadosAnimoProvider.future);
  return estados.firstOrNull;
});

/// Registra el estado de ánimo de la persona de contexto.
final registrarAnimoProvider =
    Provider<
      Future<EstadoDeAnimo> Function({
        required EstadoAnimoEnum estado,
        String? observaciones,
      })
    >((ref) {
      return ({required estado, observaciones}) async {
        final persona = await ref.read(healthPersonaContextProvider.future);
        if (persona == null) throw Exception('Sin persona de contexto');

        final repo = ref.read(healthRepositoryProvider);
        final animo = EstadoDeAnimo(
          id: '',
          persona: persona,
          fecha: DateTime.now(),
          estado: estado,
          observaciones: observaciones,
        );
        final creado = await repo.crearEstadoAnimo(animo);
        ref.invalidate(estadosAnimoProvider);
        return creado;
      };
    });
