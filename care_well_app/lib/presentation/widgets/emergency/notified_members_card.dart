import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import '../shared/avatar_initial.dart';

/// Card de un miembro notificado en la pantalla de emergencia enviada.
///
/// Muestra avatar, nombre del colaborador, su rol y un ícono de check verde.
class NotifiedMembersCard extends StatelessWidget {
  const NotifiedMembersCard({super.key, required this.asignacion});

  final AsignacionCuidado asignacion;

  @override
  Widget build(BuildContext context) {
    final persona = asignacion.colaborador;
    final rolLabel = asignacion.rol.id == RolesCuidadoConst.responsable
        ? 'Responsable'
        : 'Cuidador/a';

    return Semantics(
      label: '${persona.nombre} ${persona.apellido}, $rolLabel, notificado',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        constraints: const BoxConstraints(minHeight: 40),
        child: Row(
          children: [
            AvatarInitial(nombre: persona.nombre, size: 36),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${persona.nombre} ${persona.apellido}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    rolLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.check_circle, size: 20, color: AppColors.success),
          ],
        ),
      ),
    );
  }
}
