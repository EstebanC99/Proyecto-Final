import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

/// Historial de estados de ánimo de la persona de contexto (US-31).
class MoodHistoryScreen extends ConsumerWidget {
  const MoodHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estadosAsync = ref.watch(estadosAnimoProvider);
    final personaAsync = ref.watch(healthPersonaContextProvider);
    final nombrePersona =
        personaAsync.valueOrNull?.nombre ?? 'la persona a cargo';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Historial de ánimo'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          if (personaAsync.valueOrNull != null)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: Chip(
                label: Text(nombrePersona),
                backgroundColor: AppColors.moodContainer,
                labelStyle: const TextStyle(
                  color: AppColors.moodAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: estadosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: InlineErrorBanner(
            message: 'No se pudo cargar el historial. $err',
          ),
        ),
        data: (estados) => RefreshIndicator(
          color: AppColors.moodAccent,
          onRefresh: () async => ref.invalidate(estadosAnimoProvider),
          child: CustomScrollView(
            slivers: [
              // Gráfico de últimos 7 días
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ÚLTIMOS 7 DÍAS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        SizedBox(
                          height: 100,
                          child: MoodBarChart(estados: estados),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Encabezado registros recientes
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: Text(
                    'REGISTROS RECIENTES',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              // Lista de registros
              if (estados.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      child: Text(
                        'Aún no hay registros. Registrá el primer estado de ánimo.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.xxxl,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _MoodRecordItem(estado: estados[i]),
                      childCount: estados.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoodRecordItem extends StatelessWidget {
  const _MoodRecordItem({required this.estado});

  final EstadoDeAnimo estado;

  static int _enumToLevel(EstadoAnimoEnum e) {
    switch (e) {
      case EstadoAnimoEnum.muyMal:
        return 1;
      case EstadoAnimoEnum.mal:
        return 2;
      case EstadoAnimoEnum.regular:
        return 3;
      case EstadoAnimoEnum.bien:
        return 4;
      case EstadoAnimoEnum.muyBien:
        return 5;
    }
  }

  static String _emojiForEnum(EstadoAnimoEnum e) {
    switch (e) {
      case EstadoAnimoEnum.muyMal:
        return '😞';
      case EstadoAnimoEnum.mal:
        return '😕';
      case EstadoAnimoEnum.regular:
        return '😐';
      case EstadoAnimoEnum.bien:
        return '🙂';
      case EstadoAnimoEnum.muyBien:
        return '😄';
    }
  }

  @override
  Widget build(BuildContext context) {
    final level = _enumToLevel(estado.estado);
    final color = moodLevelColor(level);
    final fecha = DateFormat('d MMM yyyy', 'es').format(estado.fecha);

    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _emojiForEnum(estado.estado),
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fecha,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textDisabled,
                    ),
                  ),
                  if (estado.observaciones != null)
                    Text(
                      estado.observaciones!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    final fechaHora = DateFormat(
      'd MMM yyyy · HH:mm',
      'es',
    ).format(estado.fecha);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fechaHora,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textDisabled,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (estado.observaciones != null)
              Text(
                estado.observaciones!,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              )
            else
              const Text(
                'Sin observación registrada.',
                style: TextStyle(fontSize: 14, color: AppColors.textDisabled),
              ),
          ],
        ),
      ),
    );
  }
}
