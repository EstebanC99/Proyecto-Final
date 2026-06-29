import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── Selector de persona de contexto global ───────────────────────────────────

/// Rol de la persona respecto al usuario autenticado en el selector de contexto.
enum PersonaContextRol { propio, responsable, cuidador }

/// Opción de persona seleccionable en el selector de contexto global.
class PersonaContextOption {
  final Persona persona;
  final PersonaContextRol rol;

  const PersonaContextOption({required this.persona, required this.rol});
}

/// Lista completa de personas que el usuario puede seleccionar como contexto:
/// 1. El propio usuario (etiquetado con rol [PersonaContextRol.propio]).
/// 2. Personas donde es Responsable.
/// 3. Personas donde es Cuidador.
final personasSeleccionablesProvider =
    FutureProvider.autoDispose<List<PersonaContextOption>>((ref) async {
      final usuario = ref.watch(authStateProvider).valueOrNull;
      if (usuario == null) return [];

      final asignacionesActivasComoResponsable = await ref.watch(
        asignacionesActivasComoResponsableProvider.future,
      );
      final asignacionesActivasComoCuidador = await ref.watch(
        asignacionesActivasComoCuidadorProvider.future,
      );

      return [
        PersonaContextOption(
          persona: usuario.persona,
          rol: PersonaContextRol.propio,
        ),
        ...asignacionesActivasComoResponsable.map(
          (a) => PersonaContextOption(
            persona: a.personaCuidada,
            rol: PersonaContextRol.responsable,
          ),
        ),
        ...asignacionesActivasComoCuidador.map(
          (a) => PersonaContextOption(
            persona: a.personaCuidada,
            rol: PersonaContextRol.cuidador,
          ),
        ),
      ];
    });

/// ID de la persona seleccionada, cuyo contexto se está visualizando.
/// `null` = sin selección explícita → usa el propio usuario.
final personaVisualizacionSeleccionadaIdProvider = StateProvider<int?>(
  (ref) => null,
);

/// Persona de contexto activa, seleccionada globalmente.
///
/// Cuando [personaVisualizacionSeleccionadaIdProvider] es `null`, el comportamiento default es el propio usuario.
final personaVisualizacionSeleccionadaProvider =
    FutureProvider.autoDispose<Persona?>((ref) async {
      final opciones = await ref.watch(personasSeleccionablesProvider.future);
      if (opciones.isEmpty) return null;

      final selectedId = ref.watch(personaVisualizacionSeleccionadaIdProvider);

      if (selectedId == null) {
        return opciones.first.persona;
      }

      return opciones
          .map((o) => o.persona)
          .firstWhere(
            (p) => p.id == selectedId,
            orElse: () => opciones.first.persona,
          );
    });
