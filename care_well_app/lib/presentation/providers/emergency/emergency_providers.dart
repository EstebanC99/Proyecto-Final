import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/entities.dart';
import '../auth/auth_providers.dart';
import '../care_team/care_team_providers.dart';
import '../di_providers.dart';

// ─── Miembros del equipo para emergencia ─────────────────────────────────────

/// Asignaciones activas del equipo de cuidado de la persona de contexto.
///
/// Usadas para mostrar quiénes serán notificados y para enviar las notificaciones.
final equipoEmergenciaProvider = FutureProvider<List<AsignacionCuidado>>((
  ref,
) async {
  final persona = await ref.watch(careTeamContextPersonaProvider.future);
  if (persona == null) return [];
  final asignaciones = await ref
      .watch(careTeamRepositoryProvider)
      .getAsignacionesByPersonaCuidada(persona.id);
  return asignaciones
      .where((a) => a.estado.id == EstadosAsignacionConst.activa)
      .toList();
});

// ─── Permisos RBAC ────────────────────────────────────────────────────────────

/// Indica si el usuario autenticado puede activar la emergencia para la persona de contexto.
///
/// Retorna `true` automáticamente cuando el usuario visualiza su propio contexto,
/// ya que puede pedir asistencia a su propio equipo de cuidado.
final puedeActivarEmergenciaProvider = FutureProvider<bool>((ref) async {
  // Cortocircuito: el usuario siempre puede activar emergencia en su propio contexto.
  final esPropio = await ref.watch(esContextoPropioProvider.future);
  if (esPropio) return true;

  final usuario = ref.watch(authStateProvider).valueOrNull;
  if (usuario == null) return false;

  final persona = await ref.watch(careTeamContextPersonaProvider.future);
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
    (p) => p.codigo.id == PermisosCuidadoConst.activarEmergencia,
  );
});

// ─── Acción: activar emergencia ───────────────────────────────────────────────

/// Activa la emergencia para la persona de contexto.
///
/// Registra la emergencia en el repositorio y envía una notificación local
/// inmediata a cada miembro activo del equipo.
///
/// TODO(backend): cuando el backend esté disponible, reemplazar las notificaciones
/// locales por notificaciones push reales a los dispositivos remotos del equipo.
final activarEmergenciaProvider = Provider<Future<Emergencia> Function()>((
  ref,
) {
  return () async {
    final usuario = ref.read(authStateProvider).valueOrNull;
    if (usuario == null) throw Exception('Sin sesión activa');

    final persona = await ref.read(careTeamContextPersonaProvider.future);
    if (persona == null) throw Exception('Sin persona de contexto');

    final miembros = await ref.read(equipoEmergenciaProvider.future);
    final scheduler = ref.read(notificationSchedulerProvider);
    final repo = ref.read(emergencyRepositoryProvider);

    // Registrar la emergencia en el repositorio.
    final emergencia = await repo.activarEmergencia(
      personaId: persona.id,
      descripcion: null,
    );

    // Notificación local por cada miembro del equipo activo.
    for (final m in miembros) {
      final notifId = '${emergencia.id}_${m.id}'.hashCode & 0x7fffffff;
      await scheduler.showImmediateNotification(
        notificationId: notifId,
        titulo: 'Emergencia — ${persona.nombre} ${persona.apellido}',
        cuerpo:
            '${usuario.persona.nombre} está solicitando asistencia inmediata.',
        payload: emergencia.id.toString(),
      );
    }

    return emergencia;
  };
});
