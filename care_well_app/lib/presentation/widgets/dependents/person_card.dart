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

/// Tarjeta de asignación de cuidado para la lista de personas a cargo (US-13).
///
/// Muestra avatar con inicial, nombre completo, edad calculada, badge de rol
/// y —cuando la asignación está pendiente— un chip "Pendiente".
class PersonCard extends StatelessWidget {
  const PersonCard({super.key, required this.asignacion, required this.onTap});

  /// Asignación de cuidado a mostrar.
  final AsignacionCuidado asignacion;

  /// Callback al tocar la tarjeta.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final persona = asignacion.personaCuidada;
    final rolLabel = asignacion.rol.descripcion;
    final esPendiente =
        asignacion.estado.id == EstadosAsignacionConst.pendiente;
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
                          if (esPendiente) ...[
                            const SizedBox(width: AppSpacing.sm),
                            const _PendingChip(),
                          ],
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

/// Chip de estado pendiente para asignaciones en espera de aceptación.
class _PendingChip extends StatelessWidget {
  const _PendingChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: const Color(0xFFF5A623), width: 1),
      ),
      child: const Text(
        'Pendiente',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF7A5200),
        ),
      ),
    );
  }
}
