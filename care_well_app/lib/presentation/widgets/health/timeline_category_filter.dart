import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import 'health_timeline_style.dart';
import 'timeline_categorias.dart';

/// Fila de chips para filtrar la línea de tiempo por categoría.
///
/// [seleccionada] en `null` significa "Todo". El filtrado es en cliente, sobre
/// los registros del mes que ya están cargados: no dispara ninguna consulta.
class TimelineCategoryFilter extends StatelessWidget {
  const TimelineCategoryFilter({
    super.key,
    required this.seleccionada,
    required this.onChanged,
  });

  /// Categoría activa, o `null` para "Todo".
  final String? seleccionada;

  /// Emite la categoría elegida, o `null` al volver a "Todo".
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    // Sin alto fijo: la fila mide lo que miden los chips y crece con la
    // tipografía del sistema. Con un alto clavado el texto se recorta por
    // abajo, y en una lista horizontal eso no lanza ninguna excepción.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          _Chip(
            texto: 'Todo',
            activo: seleccionada == null,
            onTap: () => onChanged(null),
          ),
          for (final categoria in TimelineCategorias.todas) ...[
            const SizedBox(width: 7),
            _Chip(
              // Rótulo breve: con el largo de la fila ("Evento de salud",
              // "Estado de ánimo") los cuatro chips no entran en el ancho de
              // un teléfono y el último nace fuera de cuadro.
              texto: categoriaEventoLabelCorto(categoria),
              activo: seleccionada == categoria,
              color: categoriaEventoColor(context, categoria),
              onTap: () => onChanged(categoria),
            ),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.texto,
    required this.activo,
    required this.onTap,
    this.color,
  });

  final String texto;
  final bool activo;
  final VoidCallback onTap;

  /// Color de la categoría; `null` en "Todo", que usa el primario.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final acento = color ?? colors.primary;

    return Semantics(
      button: true,
      selected: activo,
      label: texto,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: activo ? acento : colors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
            child: Text(
              texto,
              maxLines: 1,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: activo ? colors.onPrimary : colors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
