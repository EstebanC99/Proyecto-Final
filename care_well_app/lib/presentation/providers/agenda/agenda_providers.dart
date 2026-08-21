import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../domain/entities/entities.dart';
import '../../../domain/notifications/notifications.dart';

// ─── Contexto de persona para la agenda ──────────────────────────────────────

/// Persona de contexto para la agenda (reutiliza [personaVisualizacionSeleccionadaProvider]).
final agendaPersonaContextProvider = FutureProvider<Persona?>(
  (ref) => ref.watch(personaVisualizacionSeleccionadaProvider.future),
);

// ─── Semana y día seleccionados ─────────────────────────────────────────────

/// Trunca [fecha] a año-mes-día (medianoche local).
DateTime _soloFecha(DateTime fecha) =>
    DateTime(fecha.year, fecha.month, fecha.day);

/// Lunes (00:00) de la semana a la que pertenece [fecha].
DateTime lunesDeLaSemana(DateTime fecha) =>
    _soloFecha(fecha).subtract(Duration(days: fecha.weekday - 1));

/// Lunes de la semana actualmente visible en la tira de días de la agenda.
final semanaSeleccionadaProvider = StateProvider<DateTime>(
  (ref) => lunesDeLaSemana(DateTime.now()),
);

/// Día cuyo detalle se está mostrando en la agenda (truncado a año-mes-día).
final diaSeleccionadoProvider = StateProvider<DateTime>(
  (ref) => _soloFecha(DateTime.now()),
);

/// Mueve la agenda al día indicado: lo selecciona y, si cae fuera de la semana
/// visible, mueve también la semana.
///
/// Lo usan la pantalla de agenda (al tocar un día de la tira o "Lo que sigue")
/// y el formulario de alta/edición, para que al volver quede a la vista el
/// evento recién guardado aunque sea de otra semana.
void seleccionarDiaAgenda(WidgetRef ref, DateTime dia) {
  final diaTruncado = _soloFecha(dia);
  ref.read(diaSeleccionadoProvider.notifier).state = diaTruncado;

  final lunes = lunesDeLaSemana(diaTruncado);
  if (lunes != ref.read(semanaSeleccionadaProvider)) {
    ref.read(semanaSeleccionadaProvider.notifier).state = lunes;
  }
}

/// Devuelve la agenda al día de hoy.
///
/// La selección de día y semana vive en providers globales, que sobreviven al
/// cierre de la pantalla. La agenda la llama al montarse para que cada entrada
/// arranque en el presente y no donde quedó la visita anterior.
void reiniciarSeleccionAgenda(WidgetRef ref) {
  final hoy = _soloFecha(DateTime.now());
  ref.read(diaSeleccionadoProvider.notifier).state = hoy;
  ref.read(semanaSeleccionadaProvider.notifier).state = lunesDeLaSemana(hoy);
}

/// Ocurrencias de la persona de contexto dentro de la semana seleccionada
/// (lunes a domingo), ordenadas por fecha/hora de inicio.
final ocurrenciasDeSemanaProvider =
    FutureProvider<List<OcurrenciaEventoAgenda>>((ref) async {
      final persona = await ref.watch(agendaPersonaContextProvider.future);
      final personaId = persona?.id;
      if (personaId == null) return [];

      final lunes = ref.watch(semanaSeleccionadaProvider);

      final ocurrencias = await ref
          .watch(agendaRepositoryProvider)
          .obtenerOcurrencias(
            personaId: personaId,
            desde: lunes,
            hasta: lunes.add(const Duration(days: 7)),
          );
      ocurrencias.sort(
        (a, b) => a.fechaHoraInicio.compareTo(b.fechaHoraInicio),
      );
      return ocurrencias;
    });

/// Primera ocurrencia posterior al día seleccionado, dentro de los 30 días
/// siguientes. Alimenta la sección "Lo que sigue" de la agenda.
///
/// Se busca a partir del día siguiente al seleccionado (no a partir de "ahora")
/// para que la sección siempre muestre algo distinto de lo que ya se ve en el
/// detalle del día.
final proximaOcurrenciaProvider = FutureProvider<OcurrenciaEventoAgenda?>((
  ref,
) async {
  final persona = await ref.watch(agendaPersonaContextProvider.future);
  final personaId = persona?.id;
  if (personaId == null) return null;

  final dia = ref.watch(diaSeleccionadoProvider);
  final desde = _soloFecha(dia).add(const Duration(days: 1));

  final ocurrencias = await ref
      .watch(agendaRepositoryProvider)
      .obtenerOcurrencias(
        personaId: personaId,
        desde: desde,
        hasta: desde.add(const Duration(days: 30)),
      );
  if (ocurrencias.isEmpty) return null;
  ocurrencias.sort((a, b) => a.fechaHoraInicio.compareTo(b.fechaHoraInicio));
  return ocurrencias.first;
});

// ─── Mutadores ──────────────────────────────────────────────────────────────

/// Invalida todas las vistas de ocurrencias tras una mutación.
void _invalidarOcurrencias(Ref ref) {
  ref.invalidate(ocurrenciasDeSemanaProvider);
  ref.invalidate(proximaOcurrenciaProvider);
}

/// Crea un evento de agenda (opcionalmente recurrente), refresca las
/// ocurrencias visibles y resincroniza las notificaciones locales.
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
            _invalidarOcurrencias(ref);
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
/// ocurrencias visibles y resincroniza las notificaciones locales.
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
            _invalidarOcurrencias(ref);
            try {
              await ref.read(sincronizarNotificacionesAgendaProvider)(
                motivo: SyncMotivo.mutacion,
              );
            } catch (_) {
              // sincronización de notificaciones es best-effort; no afecta el resultado
            }
          },
    );

/// Elimina el evento con el id dado, refresca las ocurrencias visibles y
/// resincroniza las notificaciones locales.
final eliminarEventoAgendaProvider =
    Provider<Future<void> Function(int eventoAgendaId)>(
      (ref) => (eventoAgendaId) async {
        await ref.read(agendaRepositoryProvider).eliminarEvento(eventoAgendaId);
        _invalidarOcurrencias(ref);
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
/// ocurrencias visibles y resincroniza las notificaciones locales.
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
        _invalidarOcurrencias(ref);
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

/// Recordatorio ya resuelto y listo para programarse en el sistema operativo.
///
/// Existe para separar la etapa de recolección (que puede fallar por red) de la
/// de publicación (que destruye el estado vigente): nada se cancela hasta tener
/// el universo completo armado en memoria.
class _RecordatorioProgramable {
  const _RecordatorioProgramable({
    required this.notificationId,
    required this.fechaHora,
    required this.titulo,
    required this.cuerpo,
  });

  final int notificationId;
  final DateTime fechaHora;
  final String titulo;
  final String cuerpo;
}

/// Resincroniza las notificaciones locales de TODAS las personas que el usuario
/// puede visualizar (propio + responsable + cuidador): cancela todo lo
/// programado una sola vez y reprograma los recordatorios de las ocurrencias
/// futuras (hasta 30 días) que tengan anticipación configurada.
///
/// El disparo por [SyncMotivo.resume] se saltea si el throttle indica que la
/// última corrida fue hace menos de la ventana configurada (15 min). Los
/// motivos [SyncMotivo.ingreso] y [SyncMotivo.mutacion] corren siempre.
///
/// Corre en dos etapas para ser resistente a fallas de red: primero recolecta
/// (etapa A) y recién después cancela y reprograma (etapa B). Un fallo durante
/// la recolección nunca deja al usuario sin recordatorios: en el peor caso
/// quedan vigentes los de la corrida anterior.
final sincronizarNotificacionesAgendaProvider =
    Provider<Future<void> Function({required SyncMotivo motivo})>(
      (ref) => ({required motivo}) async {
        final throttle = ref.read(agendaSyncThrottleProvider);
        if (motivo == SyncMotivo.resume && !throttle.deberiaCorrer()) return;

        final opciones = await ref.read(personasSeleccionablesProvider.future);
        // Sin personas visibles (típicamente, sin sesión) no hay nada que
        // reprogramar: se sale antes de cancelar para no dejar la agenda muda.
        if (opciones.isEmpty) return;

        final ahora = DateTime.now();
        final hasta = ahora.add(const Duration(days: 30));
        final agendaRepository = ref.read(agendaRepositoryProvider);

        // ─── Etapa A: recolección ───────────────────────────────────────────
        // Todavía no se tocó nada de lo programado.
        final recordatorios = <_RecordatorioProgramable>[];
        var personasResueltas = 0;

        for (final opcion in opciones) {
          final persona = opcion.persona;
          final List<OcurrenciaEventoAgenda> ocurrencias;
          try {
            ocurrencias = await agendaRepository.obtenerOcurrencias(
              personaId: persona.id,
              desde: ahora,
              hasta: hasta,
            );
          } catch (_) {
            // El fallo de una persona no debe impedir programar las demás.
            continue;
          }
          personasResueltas++;

          for (final ocu in ocurrencias) {
            final anticipacion = ocu.minutosAnticipacionRecordatorio;
            if (anticipacion == null) continue;
            final notifTime = ocu.fechaHoraInicio.subtract(
              Duration(minutes: anticipacion),
            );
            if (!notifTime.isAfter(ahora)) continue;

            final horario = _formatHoraNotificacion(
              ocu.fechaHoraInicio.toLocal(),
            );
            final tieneDesc =
                ocu.descripcion != null && ocu.descripcion!.isNotEmpty;
            recordatorios.add(
              _RecordatorioProgramable(
                notificationId: NotificationId.forOcurrencia(
                  ocu.eventoAgendaId,
                  ocu.fechaHoraInicio,
                ),
                fechaHora: notifTime,
                titulo: 'Recordatorio de ${persona.nombreCompleto}.',
                cuerpo:
                    '${ocu.titulo}: $horario.'
                    '${tieneDesc ? ' ${ocu.descripcion!}' : ''}',
              ),
            );
          }
        }

        // Fallaron todas: se conserva lo programado y NO se marca el throttle,
        // para que el próximo resume reintente sin esperar la ventana de 15 min.
        if (personasResueltas == 0) return;

        // ─── Etapa B: publicación ───────────────────────────────────────────
        // cancelAll se llama una sola vez porque a continuación se reprograma el
        // universo completo de personas (no una sola de contexto).
        final scheduler = ref.read(notificationSchedulerProvider);
        await scheduler.cancelAll();

        for (final recordatorio in recordatorios) {
          await scheduler.scheduleEventReminder(
            notificationId: recordatorio.notificationId,
            fechaHora: recordatorio.fechaHora,
            titulo: recordatorio.titulo,
            cuerpo: recordatorio.cuerpo,
          );
        }

        throttle.marcarCorrida();
      },
    );

// ─── Alarmas exactas ─────────────────────────────────────────────────────────

/// Indica si el sistema permite programar alarmas exactas.
///
/// Se invalida al volver de background (ver `_AlarmasExactasBanner`): el
/// permiso se concede en una pantalla de Ajustes externa a la app, que no
/// devuelve resultado, así que la única forma de enterarse es reconsultarlo.
final puedeProgramarAlarmasExactasProvider = FutureProvider<bool>(
  (ref) =>
      ref.watch(notificationSchedulerProvider).puedeProgramarAlarmasExactas(),
);

/// Marca si el usuario descartó el aviso de alarmas exactas.
///
/// Es estado de sesión, deliberadamente sin persistencia en disco: al reiniciar
/// el proceso el aviso vuelve a evaluarse. Un descarte no debería silenciar
/// para siempre algo que degrada todos los recordatorios.
final alarmasExactasBannerDescartadoProvider = StateProvider<bool>(
  (ref) => false,
);
