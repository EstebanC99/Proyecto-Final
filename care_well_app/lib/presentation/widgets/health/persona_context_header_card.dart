import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import '../shared/persona_avatar.dart';

/// Encabezado de solo lectura que ubica al usuario sobre a quién pertenece la
/// ficha de salud. No es interactivo: estos datos se editan desde
/// "Personas a cargo".
class PersonaContextHeaderCard extends StatelessWidget {
  const PersonaContextHeaderCard({super.key, required this.persona});

  final Persona persona;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: context.colors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PersonaAvatar(
                personaId: persona.id,
                nombre: persona.nombre,
                size: 48,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  persona.nombreCompleto,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: context.colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _InfoRow(
            icon: Icons.badge_outlined,
            text: 'DNI ${persona.documento}',
          ),
          const SizedBox(height: AppSpacing.xs),
          _InfoRow(
            icon: Icons.calendar_month,
            text: 'Nacimiento: ${_formatFecha(persona.fechaNacimiento)}',
          ),
        ],
      ),
    );
  }

  static String _formatFecha(DateTime f) {
    final d = f.day.toString().padLeft(2, '0');
    final m = f.month.toString().padLeft(2, '0');
    return '$d/$m/${f.year}';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: context.colors.textSecondary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: context.colors.textSecondary),
          ),
        ),
      ],
    );
  }
}
