import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import '../shared/persona_avatar.dart';

/// Tarjeta de miembro del equipo de cuidado (US-16).
///
/// Muestra avatar con color según rol, nombre, email, badge de rol y chevron.
/// Si [isCurrentUser] es `true`, añade " (Vos)" tras el nombre.
class MemberCard extends StatelessWidget {
  const MemberCard({
    super.key,
    required this.asignacion,
    required this.isCurrentUser,
    this.onTap,
    this.showChevron = true,
  });

  /// Asignación de cuidado a mostrar.
  final AsignacionCuidado asignacion;

  /// Indica si este miembro es el usuario autenticado.
  final bool isCurrentUser;

  /// Callback al tocar la tarjeta. Si es `null`, la tarjeta queda en modo solo lectura.
  final VoidCallback? onTap;

  /// Si es `false` oculta el chevron (útil para headers de detalle).
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final esResponsable = asignacion.rol.id == RolesCuidadoConst.responsable;
    final avatarBg = esResponsable
        ? context.colors.primaryContainer
        : context.colors.secondaryContainer;
    final badgeLabel = esResponsable ? 'Responsable' : 'Cuidador';
    final badgeBg = esResponsable
        ? context.colors.primaryContainer
        : context.colors.secondaryContainer;
    final badgeText = esResponsable
        ? context.colors.onPrimaryContainer
        : const Color(0xFF7A2E1A);

    final colaborador = asignacion.colaborador;

    return Material(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
          constraints: const BoxConstraints(minHeight: 72),
          child: Row(
            children: [
              // Avatar
              PersonaAvatar(
                personaId: colaborador.id,
                nombre: colaborador.nombre,
                size: 44,
                backgroundColor: avatarBg,
              ),
              const SizedBox(width: AppSpacing.md),
              // Columna de texto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          colaborador.nombreCompleto,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: context.colors.textPrimary,
                          ),
                        ),
                        if (isCurrentUser) ...[
                          const SizedBox(width: 4),
                          Text(
                            '(Vos)',
                            style: TextStyle(
                              fontSize: 13,
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (colaborador.email != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        colaborador.email!,
                        style: TextStyle(
                          fontSize: 13,
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Columna derecha: badge + chevron
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusFull,
                      ),
                    ),
                    child: Text(
                      badgeLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: badgeText,
                      ),
                    ),
                  ),
                  if (showChevron) ...[
                    const SizedBox(height: 6),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: context.colors.outlineStrong,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
