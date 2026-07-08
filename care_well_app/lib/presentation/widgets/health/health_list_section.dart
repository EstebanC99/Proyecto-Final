import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import 'ficha_salud_list_type.dart';

/// Contenedor de una de las 3 listas de la Ficha de salud. Muestra el header de
/// la sección (ícono + título + contador + "+ Agregar") y, debajo, las cards de
/// ítems o el estado vacío.
class HealthListSection extends StatelessWidget {
  const HealthListSection({
    super.key,
    required this.type,
    required this.itemCount,
    required this.onAdd,
    required this.children,
    this.canEdit = true,
  });

  final FichaListType type;

  /// Cantidad de ítems (para el badge contador).
  final int itemCount;

  /// Abre el bottom sheet de alta.
  final VoidCallback onAdd;

  /// Cards de los ítems ya existentes (vacío → estado vacío).
  final List<Widget> children;

  /// Cuando es `false` (modo solo lectura), oculta las acciones de alta.
  final bool canEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(type: type, count: itemCount, onAdd: onAdd, canEdit: canEdit),
          const SizedBox(height: AppSpacing.md),
          if (children.isEmpty)
            _EmptyState(type: type, onAdd: onAdd, canEdit: canEdit)
          else
            ...children,
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.type,
    required this.count,
    required this.onAdd,
    required this.canEdit,
  });

  final FichaListType type;
  final int count;
  final VoidCallback onAdd;
  final bool canEdit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(type.icon, size: 20, color: type.accent),
        const SizedBox(width: AppSpacing.sm),
        Text(
          type.sectionTitle,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const Spacer(),
        if (canEdit) _AddChip(type: type, onTap: onAdd),
      ],
    );
  }
}

class _AddChip extends StatelessWidget {
  const _AddChip({required this.type, required this.onTap});

  final FichaListType type;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            border: Border.all(color: type.accent, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, size: 16, color: type.accent),
              const SizedBox(width: 4),
              Text(
                'Agregar',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: type.accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.type,
    required this.onAdd,
    required this.canEdit,
  });

  final FichaListType type;
  final VoidCallback onAdd;
  final bool canEdit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: type.container,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(type.icon, size: 24, color: type.accent),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          type.emptyText,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        if (canEdit)
          TextButton(
            onPressed: onAdd,
            style: TextButton.styleFrom(foregroundColor: type.accent),
            child: const Text(
              '+ Agregar el primero',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
      ],
    );
  }
}
