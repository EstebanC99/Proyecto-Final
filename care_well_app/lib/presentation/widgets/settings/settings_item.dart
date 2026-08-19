import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import '../shared/icon_square.dart';

/// Ítem de lista de configuración.
///
/// Está pensado para vivir dentro de un `CardGroup`: no pinta fondo propio ni
/// dibuja separadores, eso lo aporta la tarjeta que lo contiene.
///
/// Altura mínima 56 dp, objetivo táctil mínimo 48 dp.
/// Variante [destructive]: texto e ícono en el color de error.
class SettingsItem extends StatelessWidget {
  const SettingsItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.destructive = false,
    this.iconColor,
    this.iconBackground,
    this.trailing,
    this.showChevron = true,
  });

  /// Ícono del ítem, dentro del cuadrado tintado.
  final IconData icon;

  /// Etiqueta del ítem.
  final String label;

  /// Callback al tocar el ítem.
  final VoidCallback onTap;

  /// Texto de apoyo bajo la etiqueta (hasta 2 líneas).
  final String? subtitle;

  /// Si es `true`, la etiqueta y el ícono se muestran en el color de error.
  final bool destructive;

  /// Color del ícono. Si no se pasa, lo resuelve [IconSquare] (o el color de
  /// error cuando el ítem es [destructive]).
  final Color? iconColor;

  /// Color del cuadrado del ícono. Mismo criterio que [iconColor].
  final Color? iconBackground;

  /// Widget opcional a la derecha, en lugar del chevron por defecto.
  final Widget? trailing;

  /// Si es `false` y no hay [trailing], no se muestra el chevron.
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final colorLabel = destructive
        ? context.colors.error
        : context.colors.textPrimary;

    return Semantics(
      button: true,
      label: subtitle == null ? label : '$label. $subtitle',
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              IconSquare(
                icon: icon,
                color: iconColor ?? (destructive ? context.colors.error : null),
                background:
                    iconBackground ??
                    (destructive ? context.colors.errorContainer : null),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ExcludeSemantics(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: colorLabel,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 12,
                            color: context.colors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              trailing ??
                  (showChevron
                      ? Icon(
                          Icons.chevron_right,
                          size: 20,
                          color: context.colors.textDisabled,
                        )
                      : const SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );
  }
}
