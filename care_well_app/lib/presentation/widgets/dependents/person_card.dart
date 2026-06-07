import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import '../profile/role_badge.dart';
import '../shared/avatar_initial.dart';

/// Calcula la edad en años a partir de [fechaNacimiento].
///
/// Retorna `null` si [fechaNacimiento] es nula o futura.
int? calcularEdad(DateTime? fechaNacimiento) {
  if (fechaNacimiento == null) return null;
  final hoy = DateTime.now();
  int edad = hoy.year - fechaNacimiento.year;
  final cumpleEsteAnio = DateTime(
    hoy.year,
    fechaNacimiento.month,
    fechaNacimiento.day,
  );
  if (hoy.isBefore(cumpleEsteAnio)) edad--;
  return edad < 0 ? null : edad;
}

/// Tarjeta de persona para la lista de personas a cargo (US-13).
///
/// Muestra avatar con inicial, nombre completo, edad calculada y badge de rol.
class PersonCard extends StatelessWidget {
  const PersonCard({
    super.key,
    required this.persona,
    required this.rolLabel,
    required this.onTap,
  });

  /// Persona a mostrar.
  final Persona persona;

  /// Etiqueta de rol. Ej: "Responsable", "Cuidador".
  final String rolLabel;

  /// Callback al tocar la tarjeta.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final edad = calcularEdad(persona.fechaNacimiento);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 5,
      ),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                // Avatar
                AvatarInitial(nombre: persona.nombre, size: 52),
                const SizedBox(width: AppSpacing.md),
                // Datos
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        persona.nombreCompleto,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (edad != null) ...[
                            Text(
                              '$edad años',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                          ],
                          RoleBadge(rol: rolLabel),
                        ],
                      ),
                    ],
                  ),
                ),
                // Chevron
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: AppColors.outlineStrong,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
