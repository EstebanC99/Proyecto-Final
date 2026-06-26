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

/// Plazo de gracia (en días) durante el cual una asignación eliminada puede
/// reactivarse antes de su baja definitiva.
const int _diasGraciaEliminacion = 30;

/// Construye el texto del chip de asignación eliminada con el countdown de
/// días restantes hasta la baja definitiva.
///
/// Retorna solo `"Eliminada"` si [fechaEliminacion] es nula.
String buildDeletedChipLabel(DateTime? fechaEliminacion) {
  if (fechaEliminacion == null) return 'Eliminada';
  final diasTranscurridos = DateTime.now().difference(fechaEliminacion).inDays;
  final restantes = _diasGraciaEliminacion - diasTranscurridos;
  if (restantes <= 0) return 'Eliminada · vence hoy';
  if (restantes == 1) return 'Eliminada · vence en 1 día';
  return 'Eliminada · vence en $restantes días';
}

/// Tarjeta de asignación de cuidado para la lista de personas a cargo (US-13).
///
/// Muestra avatar con inicial, nombre completo, edad calculada, badge de rol
/// y un chip de estado: "Pendiente" cuando la asignación está en espera de
/// aceptación, o "Eliminada · vence en N días" cuando está inactiva.
class PersonCard extends StatelessWidget {
  const PersonCard({super.key, required this.asignacion, required this.onTap});

  /// Asignación de cuidado a mostrar.
  final AsignacionCuidado asignacion;

  /// Callback al tocar la tarjeta. Si es `null`, la tarjeta no es interactiva
  /// y se oculta el chevron.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final persona = asignacion.personaCuidada;
    final rolLabel = asignacion.rol.descripcion;
    final esPendiente =
        asignacion.estado.id == EstadosAsignacionConst.pendiente;
    final esInactiva = asignacion.estado.id == EstadosAsignacionConst.inactiva;
    final edad = calcularEdad(persona.fechaNacimiento);

    final card = Material(
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
                        if (esInactiva) ...[
                          const SizedBox(width: AppSpacing.sm),
                          // Flexible para que el chip ceda espacio y haga
                          // ellipsis en lugar de desbordar el Row.
                          Flexible(
                            child: _DeletedChip(
                              label: buildDeletedChipLabel(
                                asignacion.fechaEliminacion,
                              ),
                            ),
                          ),
                        ] else if (esPendiente) ...[
                          const SizedBox(width: AppSpacing.sm),
                          const _PendingChip(),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Chevron (solo si la tarjeta es interactiva)
              if (onTap != null)
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: AppColors.outlineStrong,
                ),
            ],
          ),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 5,
      ),
      child: esInactiva ? Opacity(opacity: 0.6, child: card) : card,
    );
  }
}

/// Chip de estado para asignaciones eliminadas (inactivas).
///
/// Tono gris neutro; el texto incluye el countdown hasta la baja definitiva.
class _DeletedChip extends StatelessWidget {
  const _DeletedChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.outline, width: 1),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
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
