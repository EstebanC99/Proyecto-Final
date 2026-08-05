import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/entities.dart';

// ─── Miembros del equipo para emergencia ─────────────────────────────────────

/// Asignaciones activas del equipo de cuidado de la persona de contexto.
///
/// Es solo informativo: sirve para mostrar en pantalla quiénes integran el
/// equipo. El envío del aviso lo resuelve el backend con notificaciones push.
final equipoEmergenciaProvider = FutureProvider<List<AsignacionCuidado>>((
  ref,
) async {
  final persona = await ref.watch(
    personaVisualizacionSeleccionadaProvider.future,
  );
  if (persona == null) return [];
  final asignaciones = await ref.watch(
    asignacionesPorPersonaCuidadaProvider(persona.id).future,
  );
  return asignaciones
      .where((a) => a.estado.id == EstadosAsignacionConst.activa)
      .toList();
});

// ─── Historial corto ──────────────────────────────────────────────────────────

/// Últimas emergencias registradas para la persona de contexto.
///
/// `autoDispose` a propósito: la pantalla se abandona al activar una emergencia
/// (se navega a la de alerta enviada), así que al volver a entrar el provider se
/// reconstruye y el historial ya incluye la emergencia recién creada. No hace
/// falta invalidarlo a mano desde [activarEmergenciaProvider].
final historialEmergenciasProvider =
    FutureProvider.autoDispose<List<Emergencia>>((ref) async {
      final persona = await ref.watch(
        personaVisualizacionSeleccionadaProvider.future,
      );
      if (persona == null) return [];

      // El backend ya devuelve de la más reciente a la más antigua
      // (OrderByDescending por FechaHora). NO reordenar acá: sería duplicar una
      // regla que vive del otro lado y que además condiciona qué 5 llegan.
      return ref
          .read(emergencyRepositoryProvider)
          .getEmergenciasByPersona(
            persona.id,
            cantidad: EmergenciasConst.cantidadHistorialCorto,
          );
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

  final usuario = ref.watch(authStateProvider).value;
  if (usuario == null) return false;

  final persona = await ref.watch(
    personaVisualizacionSeleccionadaProvider.future,
  );
  if (persona == null) return false;

  final asignaciones = await ref.watch(
    asignacionesPorPersonaCuidadaProvider(persona.id).future,
  );

  final asignacion = asignaciones
      .where(
        (a) =>
            a.colaborador.id == usuario.persona.id &&
            a.estado.id == EstadosAsignacionConst.activa,
      )
      .firstOrNull;

  if (asignacion == null) return false;
  return asignacion.permisos.any(
    (p) => p.id == PermisosCuidadoConst.activarEmergencia,
  );
});

// ─── Acción: activar emergencia ───────────────────────────────────────────────

/// Activa la emergencia para la persona de contexto.
///
/// Solo registra la emergencia en el backend: el aviso push al equipo de
/// cuidado lo envía el servidor (excluyendo al activador y a la persona
/// cuidada), por lo que el cliente no notifica a nadie por su cuenta.
final activarEmergenciaProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final usuario = ref.read(authStateProvider).value;
    if (usuario == null) throw Exception('Sin sesión activa');

    final persona = await ref.read(
      personaVisualizacionSeleccionadaProvider.future,
    );
    if (persona == null) throw Exception('Sin persona de contexto');

    await ref
        .read(emergencyRepositoryProvider)
        .activarEmergencia(personaId: persona.id, descripcion: null);
  };
});
