import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/entities.dart';
import '../../../domain/notifications/notifications.dart';

// ─── Contexto de persona para la agenda ──────────────────────────────────────

/// Persona de contexto para la agenda (reutiliza [personaVisualizacionSeleccionadaProvider]).
final agendaPersonaContextProvider = FutureProvider<Persona?>(
  (ref) => ref.watch(personaVisualizacionSeleccionadaProvider.future),
);

// ─── Permisos de gestión ──────────────────────────────────────────────────────

/// Indica si el usuario autenticado puede gestionar la agenda de la persona
/// de contexto (alta, edición y eliminación de eventos).
///
/// Retorna `true` automáticamente cuando el usuario visualiza su propio contexto.
/// Para personas a cargo, requiere asignación activa con [PermisosCuidadoConst.gestionarAgenda].
final puedeGestionarAgendaProvider = FutureProvider<bool>((ref) async {
  // Cortocircuito: el usuario siempre puede gestionar su propia agenda.
  final esPropio = await ref.watch(esContextoPropioProvider.future);
  if (esPropio) return true;

  final usuario = ref.watch(authStateProvider).valueOrNull;
  if (usuario == null) return false;

  final persona = await ref.watch(agendaPersonaContextProvider.future);
  if (persona == null) return false;

  final repo = ref.watch(careTeamRepositoryProvider);
  final asignaciones = await repo.getAsignacionesByColaborador(
    usuario.persona.id,
  );

  final asignacion = asignaciones
      .where(
        (a) =>
            a.personaCuidada.id == persona.id &&
            a.estado.id == EstadosAsignacionConst.activa,
      )
      .firstOrNull;

  if (asignacion == null) return false;

  return asignacion.permisos.any(
    (p) => p.id == PermisosCuidadoConst.gestionarAgenda,
  );
});

// ─── Catálogo de tipos de evento ────────────────────────────────────────────

/// Catálogo completo de tipos de evento (agendables y no agendables).
final tiposEventoProvider = FutureProvider<List<TipoEvento>>((ref) async {
  return ref.watch(agendaRepositoryProvider).obtenerTiposEvento();
});

/// Tipos de evento que pueden seleccionarse al crear un evento
/// (derivado de [tiposEventoProvider], filtrando por [TipoEvento.agendable]).
final tiposEventoAgendablesProvider = FutureProvider<List<TipoEvento>>((ref) {
  return ref
      .watch(tiposEventoProvider.future)
      .then((tipos) => tipos.where((t) => t.agendable).toList());
});

// ─── Mes seleccionado y ocurrencias ─────────────────────────────────────────

/// Primer día del mes actualmente visualizado en la agenda.
final mesSeleccionadoProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, 1);
});

/// Ocurrencias de la persona de contexto dentro del mes seleccionado,
/// ordenadas por fecha/hora de inicio.
final ocurrenciasDelMesProvider = FutureProvider<List<OcurrenciaEventoAgenda>>((
  ref,
) async {
  final persona = await ref.watch(agendaPersonaContextProvider.future);
  final personaId = persona?.id;
  if (personaId == null) return [];

  final mes = ref.watch(mesSeleccionadoProvider);
  final desde = mes;
  final hasta = DateTime(mes.year, mes.month + 1, 1);

  final ocurrencias = await ref
      .watch(agendaRepositoryProvider)
      .obtenerOcurrencias(personaId: personaId, desde: desde, hasta: hasta);
  ocurrencias.sort((a, b) => a.fechaHoraInicio.compareTo(b.fechaHoraInicio));
  return ocurrencias;
});

// ─── Mutadores ──────────────────────────────────────────────────────────────

/// Crea un evento de agenda (opcionalmente recurrente), refresca las
/// ocurrencias del mes y resincroniza las notificaciones locales.
final crearEventoAgendaProvider =
    Provider<
      Future<void> Function({
        required int personaId,
        required String titulo,
        String? descripcion,
        required int tipoEventoId,
        required DateTime fechaHoraInicio,
        required int duracionMinutos,
        required bool generarEventoSalud,
        int? minutosAnticipacionRecordatorio,
        int? frecuenciaRecurrenciaId,
        int? intervaloRecurrencia,
        DateTime? fechaFinRecurrencia,
      })
    >(
      (ref) =>
          ({
            required personaId,
            required titulo,
            descripcion,
            required tipoEventoId,
            required fechaHoraInicio,
            required duracionMinutos,
            required generarEventoSalud,
            minutosAnticipacionRecordatorio,
            frecuenciaRecurrenciaId,
            intervaloRecurrencia,
            fechaFinRecurrencia,
          }) async {
            await ref
                .read(agendaRepositoryProvider)
                .crearEvento(
                  personaId: personaId,
                  titulo: titulo,
                  descripcion: descripcion,
                  tipoEventoId: tipoEventoId,
                  fechaHoraInicio: fechaHoraInicio,
                  duracionMinutos: duracionMinutos,
                  generarEventoSalud: generarEventoSalud,
                  minutosAnticipacionRecordatorio:
                      minutosAnticipacionRecordatorio,
                  frecuenciaRecurrenciaId: frecuenciaRecurrenciaId,
                  intervaloRecurrencia: intervaloRecurrencia,
                  fechaFinRecurrencia: fechaFinRecurrencia,
                );
            ref.invalidate(ocurrenciasDelMesProvider);
            try {
              await ref.read(sincronizarNotificacionesAgendaProvider)();
            } catch (_) {
              // sincronización de notificaciones es best-effort; no afecta el resultado
            }
          },
    );

/// Modifica un evento existente (sin alterar su recurrencia), refresca las
/// ocurrencias del mes y resincroniza las notificaciones locales.
final modificarEventoAgendaProvider =
    Provider<
      Future<void> Function({
        required int eventoAgendaId,
        required String titulo,
        String? descripcion,
        required int tipoEventoId,
        required DateTime fechaHoraInicio,
        required int duracionMinutos,
        required bool generarEventoSalud,
        int? minutosAnticipacionRecordatorio,
      })
    >(
      (ref) =>
          ({
            required eventoAgendaId,
            required titulo,
            descripcion,
            required tipoEventoId,
            required fechaHoraInicio,
            required duracionMinutos,
            required generarEventoSalud,
            minutosAnticipacionRecordatorio,
          }) async {
            await ref
                .read(agendaRepositoryProvider)
                .modificarEvento(
                  eventoAgendaId: eventoAgendaId,
                  titulo: titulo,
                  descripcion: descripcion,
                  tipoEventoId: tipoEventoId,
                  fechaHoraInicio: fechaHoraInicio,
                  duracionMinutos: duracionMinutos,
                  generarEventoSalud: generarEventoSalud,
                  minutosAnticipacionRecordatorio:
                      minutosAnticipacionRecordatorio,
                );
            ref.invalidate(ocurrenciasDelMesProvider);
            try {
              await ref.read(sincronizarNotificacionesAgendaProvider)();
            } catch (_) {
              // sincronización de notificaciones es best-effort; no afecta el resultado
            }
          },
    );

/// Elimina el evento con el id dado, refresca las ocurrencias del mes y
/// resincroniza las notificaciones locales.
final eliminarEventoAgendaProvider =
    Provider<Future<void> Function(int eventoAgendaId)>(
      (ref) => (eventoAgendaId) async {
        await ref.read(agendaRepositoryProvider).eliminarEvento(eventoAgendaId);
        ref.invalidate(ocurrenciasDelMesProvider);
        try {
          await ref.read(sincronizarNotificacionesAgendaProvider)();
        } catch (_) {
          // sincronización de notificaciones es best-effort; no afecta el resultado
        }
      },
    );

/// Cancela una ocurrencia puntual de un evento recurrente, refresca las
/// ocurrencias del mes y resincroniza las notificaciones locales.
final cancelarOcurrenciaProvider =
    Provider<
      Future<void> Function({
        required int eventoAgendaId,
        required DateTime fechaOcurrencia,
      })
    >(
      (ref) => ({required eventoAgendaId, required fechaOcurrencia}) async {
        await ref
            .read(agendaRepositoryProvider)
            .cancelarOcurrencia(
              eventoAgendaId: eventoAgendaId,
              fechaOcurrencia: fechaOcurrencia,
            );
        ref.invalidate(ocurrenciasDelMesProvider);
        try {
          await ref.read(sincronizarNotificacionesAgendaProvider)();
        } catch (_) {
          // sincronización de notificaciones es best-effort; no afecta el resultado
        }
      },
    );

// ─── Sincronización de notificaciones locales ───────────────────────────────

/// Resincroniza las notificaciones locales de la persona de contexto:
/// cancela todo lo programado y reprograma los recordatorios de las
/// ocurrencias futuras (hasta 30 días) que tengan anticipación configurada.
final sincronizarNotificacionesAgendaProvider =
    Provider<Future<void> Function()>(
      (ref) => () async {
        final persona = await ref.read(agendaPersonaContextProvider.future);
        final personaId = persona?.id;
        if (personaId == null) return;

        final scheduler = ref.read(notificationSchedulerProvider);
        await scheduler.cancelAll();

        final ahora = DateTime.now();
        final hasta = ahora.add(const Duration(days: 30));
        final ocurrencias = await ref
            .read(agendaRepositoryProvider)
            .obtenerOcurrencias(
              personaId: personaId,
              desde: ahora,
              hasta: hasta,
            );

        for (final ocu in ocurrencias) {
          final anticipacion = ocu.minutosAnticipacionRecordatorio;
          if (anticipacion == null) continue;
          final notifTime = ocu.fechaHoraInicio.subtract(
            Duration(minutes: anticipacion),
          );
          if (notifTime.isAfter(ahora)) {
            await scheduler.scheduleEventReminder(
              notificationId: NotificationId.forOcurrencia(
                ocu.eventoAgendaId,
                ocu.fechaHoraInicio,
              ),
              fechaHora: notifTime,
              titulo: ocu.titulo,
              cuerpo: 'Recordatorio de evento',
            );
          }
        }
      },
    );
