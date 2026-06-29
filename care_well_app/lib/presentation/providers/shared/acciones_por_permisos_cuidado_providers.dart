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

/// `true` si el usuario logueado tiene el permiso [PermisosCuidadoConst.administrarEquipo]
/// sobre la persona de contexto.
///
/// Cortocircuito: si el contexto es el propio usuario, siempre puede administrar su equipo.
final puedeAdministrarEquipoProvider = FutureProvider.autoDispose<bool>((
  ref,
) async {
  final usuarioAsync = ref.watch(authStateProvider);
  final usuario = usuarioAsync.valueOrNull;
  if (usuario == null) return false;

  final esPropio = await ref.watch(esContextoPropioProvider.future);
  if (esPropio) return true;

  final personaSeleccionada = await ref.watch(
    personaVisualizacionSeleccionadaProvider.future,
  );
  if (personaSeleccionada == null) return false;

  final asignacionesPersonaSeleccionada = await ref.watch(
    asignacionesPorPersonaCuidadaProvider(personaSeleccionada.id).future,
  );

  final propia = asignacionesPersonaSeleccionada.where(
    (a) =>
        a.colaborador.id == usuario.persona.id &&
        a.estado.id == EstadosAsignacionConst.activa,
  );
  if (propia.isEmpty) return false;

  return propia.first.permisos.any(
    (p) => p.id == PermisosCuidadoConst.administrarEquipo,
  );
});
