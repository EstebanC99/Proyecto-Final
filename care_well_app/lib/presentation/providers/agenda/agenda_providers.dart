import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/entities.dart';
import '../../../infrastructure/notifications/local_notification_scheduler.dart';
import '../auth/auth_providers.dart';
import '../care_team/care_team_providers.dart';
import '../di_providers.dart';

// ─── Contexto de persona para la agenda ──────────────────────────────────────

/// Persona de contexto para la agenda (reutiliza [careTeamContextPersonaProvider]).
final agendaPersonaContextProvider = FutureProvider<Persona?>(
  (ref) => ref.watch(careTeamContextPersonaProvider.future),
);

// ─── Permisos de gestión ──────────────────────────────────────────────────────

/// Indica si el usuario autenticado puede gestionar la agenda de la persona
/// de contexto (alta, edición y eliminación de eventos).
///
/// Retorna `true` automáticamente cuando el usuario visualiza su propio contexto.
/// Para personas a cargo, requiere asignación activa con [CodigoPermiso.gestionarAgenda].
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
            a.estado == EstadoAsignacion.activa,
      )
      .firstOrNull;

  if (asignacion == null) return false;

  return asignacion.rol.permisos.any(
    (p) => p.codigo == CodigoPermiso.gestionarAgenda,
  );
});

// ─── Eventos ──────────────────────────────────────────────────────────────────

/// Lista de eventos de la persona de contexto, ordenados cronológicamente.
final agendaEventosProvider = FutureProvider<List<EventoAgenda>>((ref) async {
  final persona = await ref.watch(agendaPersonaContextProvider.future);
  if (persona == null) return [];

  final repo = ref.watch(agendaRepositoryProvider);
  final eventos = await repo.getEventosByPersona(persona.id);
  eventos.sort((a, b) => a.fechaHoraInicio.compareTo(b.fechaHoraInicio));
  return eventos;
});

/// Evento individual por ID. Busca en la lista ya cargada.
///
/// Retorna `null` si el evento no existe.
final agendaEventoByIdProvider = FutureProvider.family<EventoAgenda?, String>((
  ref,
  eventId,
) async {
  final eventos = await ref.watch(agendaEventosProvider.future);
  return eventos.where((e) => e.id == eventId).firstOrNull;
});

/// Recordatorios de un evento por su ID.
final recordatoriosByEventoProvider =
    FutureProvider.family<List<Recordatorio>, String>((ref, eventoId) async {
      final repo = ref.watch(agendaRepositoryProvider);
      return repo.getRecordatoriosByEvento(eventoId);
    });

// ─── Acciones mutadoras ───────────────────────────────────────────────────────

/// Crea un nuevo evento de agenda y, si se solicita recordatorio, programa
/// la notificación local correspondiente.
final crearEventoAgendaProvider =
    Provider<
      Future<EventoAgenda> Function({
        required Persona personaCuidada,
        required DateTime fechaHora,
        required String descripcion,
        required bool conRecordatorio,
        required Usuario creadoPor,
      })
    >((ref) {
      return ({
        required personaCuidada,
        required fechaHora,
        required descripcion,
        required conRecordatorio,
        required creadoPor,
      }) async {
        final repo = ref.read(agendaRepositoryProvider);
        final scheduler = ref.read(notificationSchedulerProvider);

        final eventoBase = EventoAgenda(
          id: 'evt_${DateTime.now().millisecondsSinceEpoch}',
          persona: personaCuidada,
          creadoPor: creadoPor,
          titulo: descripcion,
          tipo: TipoEventoAgenda.otro,
          fechaHoraInicio: fechaHora,
        );

        final eventoCreado = await repo.crearEvento(eventoBase);

        if (conRecordatorio) {
          final recordatorio = Recordatorio(
            id: 'rec_${DateTime.now().millisecondsSinceEpoch}',
            eventoAgenda: eventoCreado,
            fechaHoraEnvio: fechaHora,
          );
          await repo.crearRecordatorio(recordatorio);

          final horaFormateada =
              '${fechaHora.hour.toString().padLeft(2, '0')}:${fechaHora.minute.toString().padLeft(2, '0')}';

          await scheduler.scheduleEventReminder(
            notificationId: LocalNotificationScheduler.notificationIdFor(
              eventoCreado.id,
            ),
            fechaHora: fechaHora,
            titulo: 'Recordatorio de salud — ${personaCuidada.nombre}',
            cuerpo: '${eventoCreado.titulo} · $horaFormateada',
            payload: eventoCreado.id,
          );
        }

        ref.invalidate(agendaEventosProvider);
        return eventoCreado;
      };
    });

/// Actualiza un evento existente y reprograma la notificación si corresponde.
///
/// Si [conRecordatorio] es `true`, cancela la notificación anterior y programa
/// la nueva. Si es `false`, solo cancela.
final actualizarEventoAgendaProvider =
    Provider<
      Future<EventoAgenda> Function({
        required EventoAgenda evento,
        required String descripcion,
        required DateTime fechaHora,
        required bool conRecordatorio,
      })
    >((ref) {
      return ({
        required evento,
        required descripcion,
        required fechaHora,
        required conRecordatorio,
      }) async {
        final repo = ref.read(agendaRepositoryProvider);
        final scheduler = ref.read(notificationSchedulerProvider);

        final eventoActualizado = evento.copyWith(
          titulo: descripcion,
          fechaHoraInicio: fechaHora,
        );

        await repo.actualizarEvento(eventoActualizado);

        // Cancelar recordatorio anterior (si existía).
        final notifId = LocalNotificationScheduler.notificationIdFor(
          eventoActualizado.id,
        );
        await scheduler.cancelEventReminder(notifId);

        // Eliminar recordatorios viejos de BD.
        final recordatoriosViejos = await repo.getRecordatoriosByEvento(
          eventoActualizado.id,
        );
        for (final r in recordatoriosViejos) {
          await repo.eliminarRecordatorio(r.id);
        }

        if (conRecordatorio) {
          final recordatorio = Recordatorio(
            id: 'rec_${DateTime.now().millisecondsSinceEpoch}',
            eventoAgenda: eventoActualizado,
            fechaHoraEnvio: fechaHora,
          );
          await repo.crearRecordatorio(recordatorio);

          final horaFormateada =
              '${fechaHora.hour.toString().padLeft(2, '0')}:${fechaHora.minute.toString().padLeft(2, '0')}';

          await scheduler.scheduleEventReminder(
            notificationId: notifId,
            fechaHora: fechaHora,
            titulo:
                'Recordatorio de salud — ${eventoActualizado.persona.nombre}',
            cuerpo: '${eventoActualizado.titulo} · $horaFormateada',
            payload: eventoActualizado.id,
          );
        }

        ref.invalidate(agendaEventosProvider);
        ref.invalidate(recordatoriosByEventoProvider(eventoActualizado.id));
        return eventoActualizado;
      };
    });

/// Elimina un evento y cancela su notificación local.
final eliminarEventoAgendaProvider =
    Provider<Future<void> Function(EventoAgenda evento)>((ref) {
      return (evento) async {
        final repo = ref.read(agendaRepositoryProvider);
        final scheduler = ref.read(notificationSchedulerProvider);

        await scheduler.cancelEventReminder(
          LocalNotificationScheduler.notificationIdFor(evento.id),
        );
        await repo.eliminarEvento(evento.id);

        ref.invalidate(agendaEventosProvider);
      };
    });
