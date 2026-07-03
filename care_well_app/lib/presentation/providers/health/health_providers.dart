import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── Contexto de persona para Mi salud ───────────────────────────────────────

/// Persona de contexto para el módulo salud (reutiliza [careTeamContextPersonaProvider]).
final healthPersonaContextProvider = FutureProvider<Persona?>(
  (ref) => ref.watch(personaVisualizacionSeleccionadaProvider.future),
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
            a.estado.id == EstadosAsignacionConst.activa,
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
    (p) => p.id == PermisosCuidadoConst.verFichaSalud,
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
    (p) => p.id == PermisosCuidadoConst.registrarEventosSalud,
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
    (p) => p.id == PermisosCuidadoConst.registrarHabitos,
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
final habitoByIdProvider = FutureProvider.family<HabitoDeVida?, int>((
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
    Provider<Future<void> Function({required int habitoId})>((ref) {
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
          id: 0,
          persona: persona,
          tipo: tipo,
          descripcion: descripcion,
        );
        final creado = await repo.crearHabito(habito);
        ref.invalidate(habitosProvider);
        return creado;
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
        required EstadoAnimo estado,
        String? observaciones,
      })
    >((ref) {
      return ({required estado, observaciones}) async {
        final persona = await ref.read(healthPersonaContextProvider.future);
        if (persona == null) throw Exception('Sin persona de contexto');

        final repo = ref.read(healthRepositoryProvider);
        final animo = EstadoDeAnimo(
          id: 0,
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
