import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';

/// Acción elegida por el usuario en la hoja de acciones de una ocurrencia.
enum OcurrenciaAccion { editar, cancelarOcurrencia, eliminar }

/// Hoja inferior con las acciones disponibles sobre una ocurrencia.
///
/// "Editar evento" solo aparece para eventos únicos (no recurrentes); para
/// ocurrencias recurrentes se ofrece "Cancelar solo esta ocurrencia" en su
/// lugar. "Eliminar" está siempre disponible (elimina el evento o toda la
/// serie). Es puramente presentacional: retorna la [OcurrenciaAccion] elegida
/// (o `null` si se descarta) y el contenedor resuelve la lógica.
abstract final class OcurrenciaActionSheet {
  /// Muestra la hoja de acciones para [ocurrencia] y retorna la acción elegida.
  static Future<OcurrenciaAccion?> show(
    BuildContext context, {
    required OcurrenciaEventoAgenda ocurrencia,
  }) {
    return showModalBottomSheet<OcurrenciaAccion>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSpacing.md),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outline,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                child: Text(
                  ocurrencia.titulo,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const Divider(height: 1, color: AppColors.outline),
              if (!ocurrencia.esRecurrente)
                _AccionTile(
                  icon: Icons.edit_outlined,
                  label: 'Editar evento',
                  onTap: () =>
                      Navigator.of(context).pop(OcurrenciaAccion.editar),
                ),
              if (ocurrencia.esRecurrente)
                _AccionTile(
                  icon: Icons.event_busy_outlined,
                  label: 'Cancelar solo esta ocurrencia',
                  onTap: () => Navigator.of(
                    context,
                  ).pop(OcurrenciaAccion.cancelarOcurrencia),
                ),
              _AccionTile(
                icon: Icons.delete_outline,
                label: ocurrencia.esRecurrente
                    ? 'Eliminar toda la serie'
                    : 'Eliminar evento',
                destructive: true,
                onTap: () =>
                    Navigator.of(context).pop(OcurrenciaAccion.eliminar),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        );
      },
    );
  }
}

class _AccionTile extends StatelessWidget {
  const _AccionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.error : AppColors.textPrimary;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
      onTap: onTap,
    );
  }
}
