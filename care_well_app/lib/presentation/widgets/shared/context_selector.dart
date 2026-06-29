import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../providers/providers.dart';

/// Selector de persona de contexto global.
///
/// Muestra un banner prominente con el nombre de la persona que se está
/// visualizando actualmente. Si hay más de una opción disponible, el banner
/// es tappable y abre un bottom sheet con la lista de personas seleccionables
/// (el propio usuario, personas a cargo como Responsable o como Cuidador).
///
/// Cuando solo hay una opción disponible, el banner se muestra sin el ícono
/// de expansión y sin comportamiento de tap.
///
/// La lógica de estado vive en [selectedPersonaIdProvider]; este widget es
/// puramente presentacional respecto a su árbol de widgets hijo.
class ContextSelector extends ConsumerWidget {
  const ContextSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personaAsync = ref.watch(personaVisualizacionSeleccionadaProvider);
    final opcionesAsync = ref.watch(personasSeleccionablesProvider);
    final selectedId = ref.watch(personaVisualizacionSeleccionadaIdProvider);

    return personaAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
      data: (persona) {
        if (persona == null) return const SizedBox.shrink();

        final opciones = opcionesAsync.valueOrNull ?? [];
        final soloUnaOpcion = opciones.length <= 1;

        // Determinar si la persona actual es el propio usuario.
        final esPropio = opciones.any(
          (o) =>
              o.persona.id == persona.id && o.rol == PersonaContextRol.propio,
        );

        final nombreCompleto = '${persona.nombre} ${persona.apellido}';
        final subtitulo = esPropio ? 'Yo' : 'Visualizando a';

        return GestureDetector(
          onTap: soloUnaOpcion
              ? null
              : () => _showPersonaSelector(context, ref, opciones, selectedId),
          child: _ContextBanner(
            nombreCompleto: nombreCompleto,
            subtitulo: subtitulo,
            interactivo: !soloUnaOpcion,
          ),
        );
      },
    );
  }

  void _showPersonaSelector(
    BuildContext context,
    WidgetRef ref,
    List<PersonaContextOption> opciones,
    int? selectedId,
  ) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _PersonaSelectorSheet(
        opciones: opciones,
        selectedId: selectedId,
        onSelect: (id) {
          ref.read(personaVisualizacionSeleccionadaIdProvider.notifier).state =
              id;
          Navigator.pop(context);
        },
      ),
    );
  }
}

// ─── Banner prominente de contexto ───────────────────────────────────────────

/// Banner horizontal que muestra la persona de contexto activa.
///
/// Ocupa el ancho disponible; fondo [AppColors.primaryContainer], radio 12.
/// La lógica de tap vive en el widget padre [ContextSelector].
class _ContextBanner extends StatelessWidget {
  const _ContextBanner({
    required this.nombreCompleto,
    required this.subtitulo,
    required this.interactivo,
  });

  final String nombreCompleto;

  /// Texto de apoyo debajo del nombre ("Visualizando a" o "Yo").
  final String subtitulo;

  /// Cuando `true` muestra el ícono `expand_more` indicando que es tappable.
  final bool interactivo;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 4, // ~12dp vertical
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Ícono de persona
          const Icon(Icons.person, size: 24, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),

          // Textos: subtítulo + nombre
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  subtitulo,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    height: 1.2,
                  ),
                ),
                Text(
                  nombreCompleto,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Ícono de expansión (solo si es interactivo)
          if (interactivo) ...[
            const SizedBox(width: AppSpacing.xs),
            const Icon(Icons.expand_more, size: 24, color: AppColors.primary),
          ],
        ],
      ),
    );
  }
}

// ─── Bottom sheet de selección ────────────────────────────────────────────────

class _PersonaSelectorSheet extends StatelessWidget {
  const _PersonaSelectorSheet({
    required this.opciones,
    required this.selectedId,
    required this.onSelect,
  });

  final List<PersonaContextOption> opciones;
  final int? selectedId;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Handle
        Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.outline,
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        // Título
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Text(
            'Visualizando a',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),

        // Lista de opciones
        ...opciones.map((opcion) {
          final isSelected = opcion.persona.id == selectedId;
          final rolLabel = switch (opcion.rol) {
            PersonaContextRol.propio => 'Yo',
            PersonaContextRol.responsable => 'Responsable',
            PersonaContextRol.cuidador => 'Cuidador/a',
          };
          final inicial = opcion.persona.nombre.isNotEmpty
              ? opcion.persona.nombre[0].toUpperCase()
              : '?';

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryContainer,
              child: Text(
                inicial,
                style: const TextStyle(
                  color: AppColors.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text('${opcion.persona.nombre} ${opcion.persona.apellido}'),
            subtitle: Text(rolLabel),
            trailing: isSelected
                ? const Icon(Icons.check, color: AppColors.primary)
                : null,
            onTap: () => onSelect(opcion.persona.id),
          );
        }),

        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}
