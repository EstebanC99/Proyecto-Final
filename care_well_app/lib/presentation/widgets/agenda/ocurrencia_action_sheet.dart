import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';

/// Acción elegida por el usuario en la hoja de acciones de una ocurrencia.
enum OcurrenciaAccion {
  editar,
  cancelarOcurrencia,

  /// Elimina un evento único (no recurrente) por completo.
  eliminarEvento,

  /// Elimina la ocurrencia elegida y todas las posteriores de una serie.
  eliminarSerieDesde,
}

/// Hoja inferior con las acciones disponibles sobre una ocurrencia.
///
/// "Editar evento" solo aparece para eventos únicos (no recurrentes); para
/// ocurrencias recurrentes se ofrece "Cancelar solo esta ocurrencia" en su
/// lugar. La acción destructiva está siempre disponible, pero cambia de
/// sentido: en un evento único lo elimina entero y en una serie corta desde la
/// ocurrencia elegida hacia adelante (el backend no borra el pasado).
///
/// Sobre una ocurrencia que ya empezó ([OcurrenciaEventoAgenda.esEditable]) no
/// queda ninguna acción válida —el backend rechaza modificar, eliminar y
/// cancelar por igual—, así que se muestran deshabilitadas con el motivo a la
/// vista. No alcanza con que el llamador filtre: la agenda evalúa esa condición
/// al construir la lista, y una ocurrencia puede empezar con la pantalla quieta.
///
/// Es puramente presentacional: retorna la [OcurrenciaAccion] elegida (o `null`
/// si se descarta) y el contenedor resuelve la lógica.
abstract final class OcurrenciaActionSheet {
  /// Muestra la hoja de acciones para [ocurrencia] y retorna la acción elegida.
  static Future<OcurrenciaAccion?> show(
    BuildContext context, {
    required OcurrenciaEventoAgenda ocurrencia,
  }) {
    return showModalBottomSheet<OcurrenciaAccion>(
      context: context,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      builder: (context) {
        // Una sola lectura del reloj para toda la hoja, y la regla vive en la
        // entidad: acá no se reinterpreta qué es "ya ocurrió".
        final editable = ocurrencia.esEditable();

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSpacing.md),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.outline,
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
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: context.colors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (!editable)
                Padding(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.lg,
                    right: AppSpacing.lg,
                    bottom: AppSpacing.sm,
                  ),
                  child: Text(
                    'Este evento ya ocurrió: no se puede modificar ni eliminar.',
                    style: TextStyle(
                      fontSize: 13,
                      color: context.colors.textSecondary,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              Divider(height: 1, color: context.colors.outline),
              if (!ocurrencia.esRecurrente)
                _AccionTile(
                  icon: Icons.edit_outlined,
                  label: 'Editar evento',
                  onTap: editable
                      ? () => Navigator.of(context).pop(OcurrenciaAccion.editar)
                      : null,
                ),
              if (ocurrencia.esRecurrente)
                _AccionTile(
                  icon: Icons.event_busy_outlined,
                  label: 'Cancelar solo esta ocurrencia',
                  onTap: editable
                      ? () => Navigator.of(
                          context,
                        ).pop(OcurrenciaAccion.cancelarOcurrencia)
                      : null,
                ),
              _AccionTile(
                icon: Icons.delete_outline,
                label: ocurrencia.esRecurrente
                    ? 'Eliminar esta y las siguientes'
                    : 'Eliminar evento',
                destructive: true,
                onTap: editable
                    ? () => Navigator.of(context).pop(
                        ocurrencia.esRecurrente
                            ? OcurrenciaAccion.eliminarSerieDesde
                            : OcurrenciaAccion.eliminarEvento,
                      )
                    : null,
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

  /// `null` deja el ítem a la vista pero inerte: la acción existe, pero no se
  /// puede ejecutar sobre esta ocurrencia.
  final VoidCallback? onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final habilitado = onTap != null;
    final color = !habilitado
        ? context.colors.textDisabled
        : destructive
        ? context.colors.error
        : context.colors.textPrimary;

    return ListTile(
      enabled: habilitado,
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
