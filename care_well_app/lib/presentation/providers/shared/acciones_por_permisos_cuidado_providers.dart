import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// `true` si la persona actualmente seleccionada es el propio usuario autenticado.
///
/// Se usa como cortocircuito en los providers de permisos: cuando el usuario
/// visualiza su propio contexto ("Yo"), tiene acceso completo sin necesidad de
/// una [AsignacionCuidado].
final esContextoPropioProvider = FutureProvider.autoDispose<bool>((ref) async {
  final usuario = ref.watch(authStateProvider).valueOrNull;
  if (usuario == null) return false;

  final persona = await ref.watch(
    personaVisualizacionSeleccionadaProvider.future,
  );
  if (persona == null) return false;

  return persona.id == usuario.persona.id;
});

/// Helper interno: obtiene la asignación activa del usuario autenticado para la
/// persona actualmente seleccionada en la visualización.
///
/// Retorna `null` si no hay usuario, si no hay persona de contexto o si el
/// usuario no tiene una asignación activa sobre ella.
Future<AsignacionCuidado?> _asignacionActivaParaContexto(Ref ref) async {
  final usuario = ref.watch(authStateProvider).valueOrNull;
  if (usuario == null) return null;

  final persona = await ref.watch(
    personaVisualizacionSeleccionadaProvider.future,
  );
  if (persona == null) return null;

  final asignaciones = await ref.watch(
    asignacionesPorPersonaCuidadaProvider(persona.id).future,
  );

  return asignaciones
      .where(
        (a) =>
            a.colaborador.id == usuario.persona.id &&
            a.estado.id == EstadosAsignacionConst.activa,
      )
      .firstOrNull;
}

/// Indica si el usuario autenticado puede gestionar el equipo de cuidad de la persona
/// de contexto (alta, edición y eliminación de eventos).
///
/// Retorna `true` automáticamente cuando el usuario visualiza su propio contexto.
/// Para personas a cargo, requiere asignación activa con [PermisosCuidadoConst.administrarEquipo].
final puedeAdministrarEquipoProvider = FutureProvider.autoDispose<bool>((
  ref,
) async {
  final esPropio = await ref.watch(esContextoPropioProvider.future);
  if (esPropio) return true;

  final asignacion = await _asignacionActivaParaContexto(ref);
  if (asignacion == null) return false;

  return asignacion.permisos.any(
    (p) => p.id == PermisosCuidadoConst.administrarEquipo,
  );
});

/// Indica si el usuario autenticado puede gestionar la agenda de la persona
/// de contexto (alta, edición y eliminación de eventos).
///
/// Retorna `true` automáticamente cuando el usuario visualiza su propio contexto.
/// Para personas a cargo, requiere asignación activa con [PermisosCuidadoConst.gestionarAgenda].
final puedeGestionarAgendaProvider = FutureProvider.autoDispose<bool>((
  ref,
) async {
  final esPropio = await ref.watch(esContextoPropioProvider.future);
  if (esPropio) return true;

  final asignacion = await _asignacionActivaParaContexto(ref);
  if (asignacion == null) return false;

  return asignacion.permisos.any(
    (p) => p.id == PermisosCuidadoConst.gestionarAgenda,
  );
});

/// Indica si el usuario autenticado puede ver la ficha de salud de la persona
/// de contexto.
///
/// Retorna `true` automáticamente cuando el usuario visualiza su propio contexto.
/// Para personas a cargo, requiere asignación activa con [PermisosCuidadoConst.verFichaSalud].
final puedeVerSaludProvider = FutureProvider.autoDispose<bool>((ref) async {
  final esPropio = await ref.watch(esContextoPropioProvider.future);
  if (esPropio) return true;

  final asignacion = await _asignacionActivaParaContexto(ref);
  if (asignacion == null) return false;
  return asignacion.permisos.any(
    (p) => p.id == PermisosCuidadoConst.verFichaSalud,
  );
});

/// Indica si el usuario autenticado puede registrar eventos de salud de la persona
/// de contexto (alta, edición y eliminación de eventos).
///
/// Retorna `true` automáticamente cuando el usuario visualiza su propio contexto.
/// Para personas a cargo, requiere asignación activa con [PermisosCuidadoConst.registrarEventosSalud].
final puedeRegistrarEventosSaludProvider = FutureProvider.autoDispose<bool>((
  ref,
) async {
  final esPropio = await ref.watch(esContextoPropioProvider.future);
  if (esPropio) return true;

  final asignacion = await _asignacionActivaParaContexto(ref);
  if (asignacion == null) return false;
  return asignacion.permisos.any(
    (p) => p.id == PermisosCuidadoConst.registrarEventosSalud,
  );
});

/// Indica si el usuario autenticado puede registrar hábitos de la persona
/// de contexto (alta, edición y eliminación de eventos).
///
/// Retorna `true` automáticamente cuando el usuario visualiza su propio contexto.
/// Para personas a cargo, requiere asignación activa con [PermisosCuidadoConst.registrarHabitos].
final puedeRegistrarHabitosProvider = FutureProvider.autoDispose<bool>((
  ref,
) async {
  final esPropio = await ref.watch(esContextoPropioProvider.future);
  if (esPropio) return true;

  final asignacion = await _asignacionActivaParaContexto(ref);
  if (asignacion == null) return false;
  return asignacion.permisos.any(
    (p) => p.id == PermisosCuidadoConst.registrarHabitos,
  );
});

/// Indica si el usuario autenticado es un miembro activo del equipo de cuidado
/// de la persona de contexto, sin exigir ningún permiso puntual.
///
/// Retorna `true` cuando el usuario visualiza su propio contexto o cuando tiene
/// una asignación de cuidado activa sobre la persona seleccionada.
///
/// Reproduce la semántica del backend (`ValidarVisualizacion`): cualquier
/// asignación activa alcanza. Se usa para acciones disponibles a todo el equipo
/// —como el registro de cumplimiento diario de hábitos (marcar realizado y
/// comentar)— que no dependen del permiso [PermisosCuidadoConst.registrarHabitos].
final esMiembroEquipoActivoProvider = FutureProvider.autoDispose<bool>((
  ref,
) async {
  final esPropio = await ref.watch(esContextoPropioProvider.future);
  if (esPropio) return true;

  final asignacion = await _asignacionActivaParaContexto(ref);
  return asignacion != null;
});
