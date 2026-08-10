import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import '../../providers/providers.dart';
import 'context_selector_compact.dart';
import 'persona_avatar.dart';

/// Variante visual del [ContextSelector].
enum ContextSelectorVariant {
  /// Banner con recuadro y borde de marca.
  ///
  /// Es el default histórico y sigue siendo el valor por defecto para no
  /// romper llamadas existentes, pero **ninguna pantalla lo usa ya**: todas
  /// pasaron a [compact]. Se conserva como alternativa disponible.
  standard,

  /// Fila compacta sin recuadro, con rótulo de sección, badge de rol y
  /// mini-avatares de las otras personas. Es la variante en uso en todas las
  /// pantallas de la app.
  compact,
}

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
/// [variant] solo cambia el widget hoja que pinta el banner: la resolución de
/// la persona, el cálculo del rol y la apertura del bottom sheet son idénticos
/// para todas las variantes.
///
/// La lógica de estado vive en [personaVisualizacionSeleccionadaIdProvider];
/// este widget es puramente presentacional respecto a su árbol de widgets hijo.
class ContextSelector extends ConsumerWidget {
  const ContextSelector({
    super.key,
    this.variant = ContextSelectorVariant.standard,
    this.eyebrow,
  });

  /// Variante visual del banner.
  final ContextSelectorVariant variant;

  /// Rótulo superior de la variante [ContextSelectorVariant.compact]
  /// (por defecto "Estás viendo"). Se ignora en la variante estándar.
  final String? eyebrow;

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

        final opciones = opcionesAsync.value ?? [];
        final soloUnaOpcion = opciones.length <= 1;

        // Rol de la persona de contexto dentro de las opciones disponibles.
        final rolActual = opciones
            .where((o) => o.persona.id == persona.id)
            .map((o) => o.rol)
            .firstOrNull;
        final esPropio = rolActual == PersonaContextRol.propio;

        final nombreCompleto = '${persona.nombre} ${persona.apellido}';

        final banner = switch (variant) {
          ContextSelectorVariant.standard => _ContextBanner(
            personaId: persona.id,
            nombreCompleto: nombreCompleto,
            subtitulo: esPropio ? 'Yo' : 'Visualizando a',
            interactivo: !soloUnaOpcion,
          ),
          ContextSelectorVariant.compact => ContextCompactBanner(
            personaId: persona.id,
            nombreCompleto: nombreCompleto,
            eyebrow: eyebrow ?? 'Estás viendo',
            rolLabel: rolActual != null ? _rolBadgeLabel(rolActual) : null,
            interactivo: !soloUnaOpcion,
            otrasPersonas: [
              for (final o in opciones)
                if (o.persona.id != persona.id)
                  (
                    id: o.persona.id,
                    nombre: '${o.persona.nombre} ${o.persona.apellido}',
                  ),
            ],
          ),
        };

        return GestureDetector(
          // opaque: la variante compacta no tiene fondo propio; sin esto los
          // toques sobre los espacios vacíos de la fila no llegarían al gesto.
          behavior: HitTestBehavior.opaque,
          onTap: soloUnaOpcion
              ? null
              : () => _showPersonaSelector(context, ref, opciones, selectedId),
          child: banner,
        );
      },
    );
  }

  /// Etiqueta corta del rol para el badge de la variante compacta.
  String _rolBadgeLabel(PersonaContextRol rol) => switch (rol) {
    PersonaContextRol.propio => 'YO',
    PersonaContextRol.responsable => 'Responsable',
    PersonaContextRol.cuidador => 'Cuidador/a',
  };

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
/// Ocupa el ancho disponible; fondo [AppPalette.surface] con borde de
/// [AppPalette.primary] y radio 12. Se resuelve como contorno y no como bloque
/// relleno para que no compita con los accesos de acción de la pantalla.
/// La lógica de tap vive en el widget padre [ContextSelector].
class _ContextBanner extends StatelessWidget {
  const _ContextBanner({
    required this.personaId,
    required this.nombreCompleto,
    required this.subtitulo,
    required this.interactivo,
  });

  /// Id de la persona de contexto, para resolver su foto de perfil.
  final int personaId;

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
        color: context.colors.surface,
        border: Border.all(color: context.colors.primary, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Avatar de la persona de contexto: foto real o iniciales.
          PersonaAvatar(personaId: personaId, nombre: nombreCompleto, size: 36),
          const SizedBox(width: AppSpacing.sm),

          // Textos: subtítulo + nombre
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  subtitulo,
                  style: TextStyle(
                    fontSize: 11,
                    color: context.colors.textSecondary,
                    height: 1.2,
                  ),
                ),
                Text(
                  nombreCompleto,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: context.colors.textPrimary,
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
            Icon(Icons.expand_more, size: 24, color: context.colors.primary),
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
            color: context.colors.outline,
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

          return ListTile(
            leading: PersonaAvatar(
              personaId: opcion.persona.id,
              nombre: opcion.persona.nombre,
              size: 40,
            ),
            title: Text('${opcion.persona.nombre} ${opcion.persona.apellido}'),
            subtitle: Text(rolLabel),
            trailing: isSelected
                ? Icon(Icons.check, color: context.colors.primary)
                : null,
            onTap: () => onSelect(opcion.persona.id),
          );
        }),

        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}
