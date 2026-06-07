import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import '../shared/avatar_initial.dart';

/// Tarjeta que muestra una [NotaEvento] con avatar del autor, autoría y contenido.
class NoteCard extends StatelessWidget {
  const NoteCard({super.key, required this.nota});

  final NotaEvento nota;

  @override
  Widget build(BuildContext context) {
    final fechaStr = DateFormat('d MMM', 'es').format(nota.fechaHora);
    final horaStr = DateFormat('HH:mm').format(nota.fechaHora);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: const Border(
          left: BorderSide(color: AppColors.healthAccent, width: 3),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D16201F),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila de autoría
          Row(
            children: [
              AvatarInitial(nombre: nota.autor.nombre, size: 28),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  '${nota.autor.nombre} ${nota.autor.apellido}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                '$fechaStr · $horaStr',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textDisabled,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Contenido
          Text(
            nota.contenido,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
