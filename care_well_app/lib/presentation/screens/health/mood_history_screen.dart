import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../config/theme/app_palette.dart';
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

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: const ContextAppBar(eyebrow: 'Historial de ánimo'),
      body: estadosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: InlineErrorBanner(
            message: 'No se pudo cargar el historial. $err',
          ),
        ),
        data: (estados) => RefreshIndicator(
          color: context.colors.moodAccent,
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
                      color: context.colors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ÚLTIMOS 7 DÍAS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: context.colors.textSecondary,
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
              SliverToBoxAdapter(
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
                      color: context.colors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              // Lista de registros
              if (estados.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      child: Text(
                        'Aún no hay registros. Registrá el primer estado de ánimo.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: context.colors.textSecondary,
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

  final PersonaEstadoAnimo estado;

  @override
  Widget build(BuildContext context) {
    final level = moodLevel(estado.estado);
    final color = moodLevelColor(context.colors, level);
    final fecha = DateFormat('d MMM yyyy', 'es').format(estado.fecha);

    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.colors.surface,
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
                  moodEmoji(estado.estado),
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
                    style: TextStyle(
                      fontSize: 11,
                      color: context.colors.textDisabled,
                    ),
                  ),
                  if (estado.observaciones != null)
                    Text(
                      estado.observaciones!,
                      style: TextStyle(
                        fontSize: 13,
                        color: context.colors.textPrimary,
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
              style: TextStyle(
                fontSize: 12,
                color: context.colors.textDisabled,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (estado.observaciones != null)
              Text(
                estado.observaciones!,
                style: TextStyle(
                  fontSize: 15,
                  color: context.colors.textPrimary,
                  height: 1.5,
                ),
              )
            else
              Text(
                'Sin observación registrada.',
                style: TextStyle(
                  fontSize: 14,
                  color: context.colors.textDisabled,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
