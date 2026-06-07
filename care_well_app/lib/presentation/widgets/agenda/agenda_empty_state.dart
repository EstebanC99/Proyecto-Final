import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';
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
              decoration: const BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_month_outlined,
                size: 52,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const Text(
              'No hay eventos agendados',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Los eventos de salud, citas médicas y recordatorios aparecerán aquí.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
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
