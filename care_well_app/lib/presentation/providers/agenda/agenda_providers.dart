import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/entities.dart';
import '../../../domain/notifications/notifications.dart';

// ─── Contexto de persona para la agenda ──────────────────────────────────────

/// Persona de contexto para la agenda (reutiliza [personaVisualizacionSeleccionadaProvider]).
final agendaPersonaContextProvider = FutureProvider<Persona?>(
  (ref) => ref.watch(personaVisualizacionSeleccionadaProvider.future),
);

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
              await ref.read(sincronizarNotificacionesAgendaProvider)(
                motivo: SyncMotivo.mutacion,
              );
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
              await ref.read(sincronizarNotificacionesAgendaProvider)(
                motivo: SyncMotivo.mutacion,
              );
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
          await ref.read(sincronizarNotificacionesAgendaProvider)(
            motivo: SyncMotivo.mutacion,
          );
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
          await ref.read(sincronizarNotificacionesAgendaProvider)(
            motivo: SyncMotivo.mutacion,
          );
        } catch (_) {
          // sincronización de notificaciones es best-effort; no afecta el resultado
        }
      },
    );

// ─── Sincronización de notificaciones locales ───────────────────────────────

/// Formatea la hora en 24h (`HH:mm`), consistente con
/// [OcurrenciaCard._formatHora]. Se espera recibir el `DateTime` ya
/// convertido a hora local.
String _formatHoraNotificacion(DateTime dt) =>
    '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

/// Motivo por el que se dispara la resincronización de notificaciones.
///
/// - [ingreso]: entrada al área autenticada (login / cold-start ya logueado).
///   Corre siempre, sin throttle.
/// - [resume]: retorno de background. Corre solo si el throttle lo permite.
/// - [mutacion]: alta/baja/modificación/cancelación de un evento. Corre
///   siempre, sin throttle.
enum SyncMotivo { ingreso, resume, mutacion }

/// Estado de throttle para la resincronización disparada por [SyncMotivo.resume].
///
/// Vive en un provider keepAlive para sobrevivir a la recreación del `AppShell`
/// entre pantallas y mantener el registro de la última corrida durante la sesión.
class AgendaSyncThrottle {
  AgendaSyncThrottle({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;
  DateTime? _ultimaCorrida;

  /// Indica si debería correr una nueva sincronización según la [ventana]:
  /// `true` si nunca corrió o si transcurrió al menos [ventana] desde la última.
  bool deberiaCorrer({Duration ventana = const Duration(minutes: 15)}) {
    final ultima = _ultimaCorrida;
    if (ultima == null) return true;
    return _clock().difference(ultima) >= ventana;
  }

  /// Registra el instante de la última corrida efectiva.
  void marcarCorrida() => _ultimaCorrida = _clock();
}

/// Registro (keepAlive) de la última resincronización, usado para aplicar
/// throttle a los disparos por [SyncMotivo.resume].
final agendaSyncThrottleProvider = Provider<AgendaSyncThrottle>(
  (ref) => AgendaSyncThrottle(),
);

/// Resincroniza las notificaciones locales de TODAS las personas que el usuario
/// puede visualizar (propio + responsable + cuidador): cancela todo lo
/// programado una sola vez y reprograma los recordatorios de las ocurrencias
/// futuras (hasta 30 días) que tengan anticipación configurada.
///
/// El disparo por [SyncMotivo.resume] se saltea si el throttle indica que la
/// última corrida fue hace menos de la ventana configurada (15 min). Los
/// motivos [SyncMotivo.ingreso] y [SyncMotivo.mutacion] corren siempre.
final sincronizarNotificacionesAgendaProvider =
    Provider<Future<void> Function({required SyncMotivo motivo})>(
      (ref) => ({required motivo}) async {
        final throttle = ref.read(agendaSyncThrottleProvider);
        if (motivo == SyncMotivo.resume && !throttle.deberiaCorrer()) return;

        final opciones = await ref.read(personasSeleccionablesProvider.future);
        if (opciones.isEmpty) return;

        final scheduler = ref.read(notificationSchedulerProvider);
        // cancelAll se llama una sola vez porque a continuación se reprograma el
        // universo completo de personas (no una sola de contexto).
        await scheduler.cancelAll();

        final ahora = DateTime.now();
        final hasta = ahora.add(const Duration(days: 30));
        final agendaRepository = ref.read(agendaRepositoryProvider);

        for (final opcion in opciones) {
          final persona = opcion.persona;
          final ocurrencias = await agendaRepository.obtenerOcurrencias(
            personaId: persona.id,
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
              final horario = _formatHoraNotificacion(
                ocu.fechaHoraInicio.toLocal(),
              );
              final tieneDesc =
                  ocu.descripcion != null && ocu.descripcion!.isNotEmpty;
              final titulo = 'Recordatorio de ${persona.nombreCompleto}.';
              final cuerpo =
                  '${ocu.titulo}: $horario.'
                  '${tieneDesc ? ' ${ocu.descripcion!}' : ''}';
              await scheduler.scheduleEventReminder(
                notificationId: NotificationId.forOcurrencia(
                  ocu.eventoAgendaId,
                  ocu.fechaHoraInicio,
                ),
                fechaHora: notifTime,
                titulo: titulo,
                cuerpo: cuerpo,
              );
            }
          }
        }

        throttle.marcarCorrida();
      },
    );
