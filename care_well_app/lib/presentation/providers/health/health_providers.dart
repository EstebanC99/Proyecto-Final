import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── Contexto de persona para Mi salud ───────────────────────────────────────

/// Persona de contexto para el módulo salud (reutiliza [careTeamContextPersonaProvider]).
final healthPersonaContextProvider = FutureProvider<Persona?>(
  (ref) => ref.watch(personaVisualizacionSeleccionadaProvider.future),
);

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
