import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import '../shared/primary_button.dart';

/// Estado vacío para la pantalla de agenda.
///
/// Muestra un ícono de calendario, mensaje descriptivo y, cuando
/// [puedeGestionar] es `true` y [onCrear] no es nulo, un botón para crear
/// el primer evento.
class AgendaEmptyState extends StatelessWidget {
  const AgendaEmptyState({
    super.key,
    required this.puedeGestionar,
    this.onCrear,
  });

  final bool puedeGestionar;
  final VoidCallback? onCrear;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: context.colors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_month_outlined,
                size: 52,
                color: context.colors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'No hay eventos agendados',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Los eventos de salud, citas médicas y recordatorios aparecerán aquí.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: context.colors.textSecondary,
                height: 1.5,
              ),
            ),
            if (puedeGestionar && onCrear != null) ...[
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(label: 'Crear evento', onPressed: onCrear),
            ],
          ],
        ),
      ),
    );
  }
}
