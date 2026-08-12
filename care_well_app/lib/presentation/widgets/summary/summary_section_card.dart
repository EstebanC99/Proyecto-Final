import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';

/// Variantes visuales de [SummarySectionCard].
enum SummarySectionVariant {
  /// Card estándar sobre [AppPalette.surface] con elevación 1.
  surface,

  /// Card de advertencia: fondo [AppPalette.warningContainer], borde teñido y
  /// sin sombra (el color ya la separa del fondo).
  warning,
}

/// Chrome común de las cards de la pantalla de Resumen (US 9.16).
///
/// Encapsula el encabezado (caja de ícono, título, meta y trailing opcional) y
/// el contenedor, para que cada sección aporte solo su contenido. Es puramente
/// presentacional: no conoce providers ni entidades.
///
/// La animación de entrada vive acá, así todas las secciones comparten la misma
/// curva y el escalonado se controla desde la pantalla con [delay].
class SummarySectionCard extends StatelessWidget {
  const SummarySectionCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.title,
    this.meta,
    this.trailing,
    this.onTapHeader,
    this.expandido,
    this.variant = SummarySectionVariant.surface,
    this.delay = Duration.zero,
    this.child,
    this.contentPadding = const EdgeInsets.fromLTRB(
      AppSpacing.lg,
      0,
      AppSpacing.lg,
      AppSpacing.lg,
    ),
  });

  /// Ícono de la sección.
  final IconData icon;

  /// Color del ícono (acento del módulo al que pertenece la sección).
  final Color iconColor;

  /// Fondo de la caja del ícono (container del módulo).
  final Color iconBackgroundColor;

  final String title;

  /// Dato corto a la derecha del título (ej. "4 de 6", "2 registros").
  final String? meta;

  /// Widget al final del encabezado (ej. el chevron de una card colapsable).
  final Widget? trailing;

  /// Si se provee, el encabezado se vuelve interactivo (card colapsable).
  final VoidCallback? onTapHeader;

  /// Estado de la card colapsable. Solo se usa junto con [onTapHeader]: expone
  /// el estado "contraído/expandido" al lector de pantalla, que de otro modo
  /// solo vería el chevron (información puramente visual).
  final bool? expandido;

  final SummarySectionVariant variant;

  /// Retardo de la animación de entrada. Lo gestiona la pantalla.
  final Duration delay;

  /// Cuerpo de la sección. Si es `null`, la card queda solo con el encabezado.
  final Widget? child;

  /// Padding del cuerpo. Una card colapsable lo pone en cero para manejarlo
  /// desde adentro y poder plegarse a altura cero.
  final EdgeInsetsGeometry contentPadding;

  bool get _esWarning => variant == SummarySectionVariant.warning;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sinAnimacion = MediaQuery.disableAnimationsOf(context);

    final header = _Header(
      icon: icon,
      iconColor: iconColor,
      iconBackgroundColor: iconBackgroundColor,
      title: title,
      meta: meta,
      trailing: trailing,
    );

    return FadeInUp(
      duration: const Duration(milliseconds: 400),
      delay: delay,
      from: 12,
      animate: !sinAnimacion,
      child: Container(
        decoration: BoxDecoration(
          color: _esWarning ? colors.warningContainer : colors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: _esWarning
              ? Border.all(color: colors.warning.withValues(alpha: 0.5))
              : null,
          boxShadow: _esWarning ? AppSpacing.elev0 : AppSpacing.elev1,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (onTapHeader == null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: header,
              )
            else
              // Un único nodo semántico para todo el encabezado: se anuncia
              // como botón, con el estado contraído/expandido y el texto ya
              // reunido. Se excluye la semántica de los hijos (título, meta y
              // chevron) para no repetir lo mismo tres veces.
              Semantics(
                container: true,
                button: true,
                expanded: expandido,
                label: meta == null ? title : '$title, $meta',
                onTap: onTapHeader,
                excludeSemantics: true,
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  child: InkWell(
                    onTap: onTapHeader,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: AppSpacing.minTapTarget,
                        ),
                        child: header,
                      ),
                    ),
                  ),
                ),
              ),
            if (child != null) Padding(padding: contentPadding, child: child),
          ],
        ),
      ),
    );
  }
}

/// Encabezado compartido: caja de ícono + título + meta + trailing.
class _Header extends StatelessWidget {
  const _Header({
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.title,
    this.meta,
    this.trailing,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final String title;
  final String? meta;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconBackgroundColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 22, color: iconColor),
        ),
        const SizedBox(width: AppSpacing.md),
        // El título se declara como header semántico: el lector de pantalla
        // puede saltar de sección en sección.
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
                // También en la variante warning: `warning` sobre
                // `warningContainer` no alcanza el contraste de texto.
                color: context.colors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        if (meta != null) ...[
          const SizedBox(width: AppSpacing.sm),
          Text(
            meta!,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: context.colors.textSecondary,
            ),
          ),
        ],
        if (trailing != null) ...[
          const SizedBox(width: AppSpacing.sm),
          trailing!,
        ],
      ],
    );
  }
}
