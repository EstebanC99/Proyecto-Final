import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import '../shared/persona_avatar.dart';

/// Card de un miembro del equipo de cuidado en la pantalla de alerta enviada.
///
/// Muestra avatar, nombre del colaborador y su rol. El ícono de campana en
/// color neutro comunica "destinatario del aviso": el cliente no puede
/// verificar la recepción, así que no debe afirmarla con un check de éxito.
class EmergencyTeamMemberCard extends StatelessWidget {
  const EmergencyTeamMemberCard({super.key, required this.asignacion});

  final AsignacionCuidado asignacion;

  @override
  Widget build(BuildContext context) {
    final persona = asignacion.colaborador;
    final rolLabel = asignacion.rol.id == RolesCuidadoConst.responsable
        ? 'Responsable'
        : 'Cuidador/a';

    return Semantics(
      label: '${persona.nombre} ${persona.apellido}, $rolLabel',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        constraints: const BoxConstraints(minHeight: 40),
        child: Row(
          children: [
            PersonaAvatar(
              personaId: persona.id,
              nombre: persona.nombre,
              size: 36,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${persona.nombre} ${persona.apellido}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  Text(
                    rolLabel,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.notifications_active_outlined,
              size: 20,
              color: context.colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
