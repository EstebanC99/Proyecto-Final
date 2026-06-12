import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';

/// Card de solo lectura para una [RecomendacionMedica].
class RecommendationCard extends StatelessWidget {
  const RecommendationCard({super.key, required this.recomendacion});

  final RecomendacionMedica recomendacion;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: AppSpacing.elev1,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.healthContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.medical_services_outlined,
              size: 20,
              color: AppColors.healthAccent,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (recomendacion.profesional.isNotEmpty)
                  Text(
                    recomendacion.profesional,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.healthAccent,
                    ),
                  ),
                if (recomendacion.profesional.isNotEmpty)
                  const SizedBox(height: 2),
                Text(
                  recomendacion.descripcion,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
