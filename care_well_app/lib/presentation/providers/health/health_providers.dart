import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── Contexto de persona para Mi salud ───────────────────────────────────────

/// Persona de contexto para el módulo salud (reutiliza [careTeamContextPersonaProvider]).
final healthPersonaContextProvider = FutureProvider<Persona?>(
  (ref) => ref.watch(personaVisualizacionSeleccionadaProvider.future),
);

// ─── Hábitos de vida ──────────────────────────────────────────────────────────

/// Lista de hábitos de la persona de contexto.
final habitosProvider = FutureProvider<List<HabitoDeVida>>((ref) async {
  final persona = await ref.watch(healthPersonaContextProvider.future);
  if (persona == null) return [];
  return ref
      .watch(habitoVidaRepositoryProvider)
      .getHabitosByPersona(persona.id);
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

/// Primer día del mes actualmente visualizado en eventos de salud.
///
/// Compartido entre la lista de eventos (US-30) y el historial (US-33).
final mesEventosSaludProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, 1);
});

/// Eventos de salud de la persona de contexto dentro del mes seleccionado,
/// ordenados ascendente por fecha/hora.
final eventosSaludDelMesProvider = FutureProvider<List<EventoDeSalud>>((
  ref,
) async {
  final persona = await ref.watch(healthPersonaContextProvider.future);
  if (persona == null) return [];

  final mes = ref.watch(mesEventosSaludProvider);
  final desde = mes;
  final hasta = DateTime(mes.year, mes.month + 1, 1);

  final eventos = await ref
      .watch(eventoSaludRepositoryProvider)
      .getEventosSaludDelMes(personaId: persona.id, desde: desde, hasta: hasta);
  eventos.sort((a, b) => a.fechaHora.compareTo(b.fechaHora));
  return eventos;
});

/// Evento de salud individual por ID. Busca en la lista del mes ya cargada.
///
/// Retorna `null` si no existe en el mes seleccionado.
final eventoSaludByIdProvider = FutureProvider.family<EventoDeSalud?, int>((
  ref,
  id,
) async {
  final eventos = await ref.watch(eventosSaludDelMesProvider.future);
  return eventos.where((e) => e.id == id).firstOrNull;
});

// ─── Notas de eventos de salud ───────────────────────────────────────────────

/// Notas del evento con [eventoId], derivadas de la lista del mes (ya vienen
/// embebidas en el evento), ordenadas cronológicamente ascendente.
final notasByEventoProvider = Provider.family<List<NotaEvento>, int>((
  ref,
  eventoId,
) {
  final eventos = ref.watch(eventosSaludDelMesProvider).valueOrNull ?? [];
  final evento = eventos.where((e) => e.id == eventoId).firstOrNull;
  final notas = [...?evento?.notas];
  notas.sort((a, b) => a.fechaHora.compareTo(b.fechaHora));
  return notas;
});

// ─── Estados de ánimo ─────────────────────────────────────────────────────────

/// Estados de ánimo de la persona de contexto dentro del mes actual, ordenados
/// descendente por fecha (el más reciente primero).
final estadosAnimoProvider = FutureProvider<List<EstadoDeAnimo>>((ref) async {
  final persona = await ref.watch(healthPersonaContextProvider.future);
  if (persona == null) return [];
  final ahora = DateTime.now();
  final desde = DateTime(ahora.year, ahora.month, 1);
  final hasta = DateTime(ahora.year, ahora.month + 1, 1);
  final estados = await ref
      .watch(estadoAnimoRepositoryProvider)
      .obtenerPorFechas(persona: persona, desde: desde, hasta: hasta);
  return estados..sort((a, b) => b.fecha.compareTo(a.fecha));
});

/// Estado de ánimo registrado hoy para la persona de contexto, o `null`.
final animoHoyProvider = FutureProvider<EstadoDeAnimo?>((ref) async {
  final persona = await ref.watch(healthPersonaContextProvider.future);
  if (persona == null) return null;
  return ref.watch(estadoAnimoRepositoryProvider).obtenerAnimoHoy(persona);
});

// ─── Acciones mutadoras ───────────────────────────────────────────────────────

/// Hábito de vida individual por ID. Busca en la lista ya cargada.
///
/// Retorna `null` si no existe.
final habitoByIdProvider = FutureProvider.family<HabitoDeVida?, int>((
  ref,
  id,
) async {
  final habitos = await ref.watch(habitosProvider.future);
  return habitos.where((h) => h.id == id).firstOrNull;
});

/// Modifica el tipo y descripción de un hábito e invalida la lista.
final modificarHabitoProvider =
    Provider<
      Future<void> Function({
        required int habitoId,
        required int tipoId,
        required String descripcion,
      })
    >((ref) {
      return ({
        required habitoId,
        required tipoId,
        required descripcion,
      }) async {
        await ref
            .read(habitoVidaRepositoryProvider)
            .modificarHabito(
              habitoId: habitoId,
              tipoId: tipoId,
              descripcion: descripcion,
            );
        ref.invalidate(habitosProvider);
        ref.invalidate(habitoByIdProvider(habitoId));
      };
    });

/// Elimina un hábito de vida e invalida la lista.
final eliminarHabitoProvider =
    Provider<Future<void> Function({required int habitoId})>((ref) {
      return ({required habitoId}) async {
        await ref.read(habitoVidaRepositoryProvider).eliminarHabito(habitoId);
        ref.invalidate(habitosProvider);
      };
    });

/// Crea un hábito de vida para la persona de contexto e invalida la lista.
final crearHabitoProvider =
    Provider<
      Future<void> Function({required int tipoId, required String descripcion})
    >((ref) {
      return ({required tipoId, required descripcion}) async {
        final persona = await ref.read(healthPersonaContextProvider.future);
        if (persona == null) throw Exception('Sin persona de contexto');
        await ref
            .read(habitoVidaRepositoryProvider)
            .crearHabito(
              personaId: persona.id,
              tipoId: tipoId,
              descripcion: descripcion,
            );
        ref.invalidate(habitosProvider);
      };
    });

/// Registra que el hábito fue realizado hoy e invalida la lista.
final crearRealizacionProvider =
    Provider<
      Future<void> Function({required int habitoId, String? comentarios})
    >((ref) {
      return ({required habitoId, comentarios}) async {
        await ref
            .read(habitoVidaRepositoryProvider)
            .crearRealizacion(habitoId: habitoId, comentarios: comentarios);
        ref.invalidate(habitosProvider);
        ref.invalidate(habitoByIdProvider(habitoId));
      };
    });

/// Modifica el comentario de una realización e invalida la lista.
final modificarRealizacionProvider =
    Provider<
      Future<void> Function({
        required int habitoId,
        required int realizacionId,
        String? comentarios,
      })
    >((ref) {
      return ({required habitoId, required realizacionId, comentarios}) async {
        await ref
            .read(habitoVidaRepositoryProvider)
            .modificarRealizacion(
              habitoId: habitoId,
              realizacionId: realizacionId,
              comentarios: comentarios,
            );
        ref.invalidate(habitosProvider);
        ref.invalidate(habitoByIdProvider(habitoId));
      };
    });

/// Elimina la realización de hoy de un hábito e invalida la lista.
final eliminarRealizacionProvider =
    Provider<
      Future<void> Function({required int habitoId, required int realizacionId})
    >((ref) {
      return ({required habitoId, required realizacionId}) async {
        await ref
            .read(habitoVidaRepositoryProvider)
            .eliminarRealizacion(
              habitoId: habitoId,
              realizacionId: realizacionId,
            );
        ref.invalidate(habitosProvider);
        ref.invalidate(habitoByIdProvider(habitoId));
      };
    });

/// Crea un evento de salud para la persona de contexto e invalida la lista del mes.
final crearEventoSaludProvider =
    Provider<
      Future<void> Function({
        required int tipoId,
        required String descripcion,
        required DateTime fechaHora,
      })
    >((ref) {
      return ({
        required tipoId,
        required descripcion,
        required fechaHora,
      }) async {
        final persona = await ref.read(healthPersonaContextProvider.future);
        if (persona == null) throw Exception('Sin persona de contexto');

        await ref
            .read(eventoSaludRepositoryProvider)
            .crearEventoSalud(
              personaId: persona.id,
              tipoId: tipoId,
              fechaHora: fechaHora,
              descripcion: descripcion,
            );
        ref.invalidate(eventosSaludDelMesProvider);
      };
    });

/// Elimina un evento de salud e invalida la lista del mes.
final eliminarEventoSaludProvider =
    Provider<Future<void> Function({required int eventoId})>((ref) {
      return ({required eventoId}) async {
        await ref
            .read(eventoSaludRepositoryProvider)
            .eliminarEventoSalud(eventoId);
        ref.invalidate(eventosSaludDelMesProvider);
      };
    });

/// Agrega una nota a un evento de salud e invalida la lista del mes.
final agregarNotaEventoProvider =
    Provider<
      Future<void> Function({
        required int eventoSaludId,
        required String contenido,
      })
    >((ref) {
      return ({required eventoSaludId, required contenido}) async {
        await ref
            .read(eventoSaludRepositoryProvider)
            .agregarNota(eventoSaludId: eventoSaludId, contenido: contenido);
        ref.invalidate(eventosSaludDelMesProvider);
      };
    });

/// Modifica el contenido de una nota e invalida la lista del mes.
final modificarNotaEventoProvider =
    Provider<
      Future<void> Function({
        required int eventoSaludId,
        required int notaId,
        required String contenido,
      })
    >((ref) {
      return ({
        required eventoSaludId,
        required notaId,
        required contenido,
      }) async {
        await ref
            .read(eventoSaludRepositoryProvider)
            .modificarNota(
              eventoSaludId: eventoSaludId,
              notaId: notaId,
              contenido: contenido,
            );
        ref.invalidate(eventosSaludDelMesProvider);
      };
    });

/// Elimina una nota de un evento de salud e invalida la lista del mes.
final eliminarNotaEventoProvider =
    Provider<
      Future<void> Function({required int eventoSaludId, required int notaId})
    >((ref) {
      return ({required eventoSaludId, required notaId}) async {
        await ref
            .read(eventoSaludRepositoryProvider)
            .eliminarNota(eventoSaludId: eventoSaludId, notaId: notaId);
        ref.invalidate(eventosSaludDelMesProvider);
      };
    });

/// Registra el estado de ánimo de la persona de contexto e invalida los
/// providers de ánimo (el de hoy y la lista del mes).
final registrarAnimoProvider =
    Provider<
      Future<void> Function({required int estadoAnimoId, String? observaciones})
    >((ref) {
      return ({required estadoAnimoId, observaciones}) async {
        final persona = await ref.read(healthPersonaContextProvider.future);
        if (persona == null) throw Exception('No hay persona de contexto');

        await ref
            .read(estadoAnimoRepositoryProvider)
            .registrar(
              personaId: persona.id,
              estadoAnimoId: estadoAnimoId,
              observaciones: observaciones,
            );
        ref.invalidate(animoHoyProvider);
        ref.invalidate(estadosAnimoProvider);
      };
    });
