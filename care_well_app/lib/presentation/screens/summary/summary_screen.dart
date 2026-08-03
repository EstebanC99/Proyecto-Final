import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

/// Pantalla de Resumen inteligente (US 9.16).
///
/// Genera on-demand un resumen narrativo de la persona de contexto al abrirse y
/// al cambiar de persona (el provider observa
/// [personaVisualizacionSeleccionadaProvider]). El botón de la AppBar y el
/// pull-to-refresh fuerzan una regeneración invalidando
/// [resumenInteligenteProvider]. No hay caché.
///
/// Ambos disparadores están guardados contra pedidos duplicados: mientras haya
/// una generación en curso, el botón queda deshabilitado y el pull-to-refresh
/// se limita a esperar la generación ya en marcha.
class SummaryScreen extends ConsumerWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personaAsync = ref.watch(personaVisualizacionSeleccionadaProvider);
    final resumenAsync = ref.watch(resumenInteligenteProvider);

    // El botón "Actualizar" se deshabilita mientras se resuelve la persona o
    // se está generando el resumen, para no encadenar pedidos.
    final cargando = personaAsync.isLoading || resumenAsync.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Resumen'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: cargando
                ? null
                : () => ref.invalidate(resumenInteligenteProvider),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selector de persona de contexto (solo si hay persona).
          personaAsync.when(
            data: (persona) => persona != null
                ? const Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      0,
                    ),
                    child: ContextSelector(),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (e, st) => const SizedBox.shrink(),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                // Guard equivalente al del botón "Actualizar": si ya hay una
                // generación en curso no se invalida (una segunda petición
                // desperdiciaría otra inferencia de IA en CPU). Igual se
                // espera al future en curso para que el spinner del pull
                // acompañe a la generación y el usuario tenga feedback.
                if (!ref.read(resumenInteligenteProvider).isLoading) {
                  ref.invalidate(resumenInteligenteProvider);
                }
                await ref.read(resumenInteligenteProvider.future);
              },
              child: _buildBody(context, ref, personaAsync, resumenAsync),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<Persona?> personaAsync,
    AsyncValue<ResumenInteligente?> resumenAsync,
  ) {
    // Sin persona seleccionada: mismo patrón que HealthScreen.
    if (personaAsync.value == null && !personaAsync.isLoading) {
      return _scrollable(
        const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Text(
              'Primero agregá una persona a cargo para ver el resumen.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ),
      );
    }

    return resumenAsync.when(
      skipLoadingOnRefresh: false,
      loading: () => _scrollable(
        const Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: SummaryLoadingSkeleton(),
        ),
      ),
      error: (err, _) => _scrollable(
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: InlineErrorBanner(
            message: 'No se pudo generar el resumen. $err',
            actionLabel: 'Reintentar',
            onAction: () => ref.invalidate(resumenInteligenteProvider),
          ),
        ),
      ),
      data: (resumen) {
        // Sin persona (resuelto): estado ya cubierto arriba salvo carreras.
        if (resumen == null) {
          return _scrollable(const SizedBox.shrink());
        }

        // Éxito sin datos: empty state neutro, sin narrativa ni disclaimer.
        if (!resumen.tieneDatos || resumen.texto == null) {
          return _scrollable(
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
              child: SummaryEmptyState(),
            ),
          );
        }

        // Éxito con datos.
        return _scrollable(
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: SummaryGenerationChip(generadoEn: resumen.generadoEn),
                ),
                const SizedBox(height: AppSpacing.md),
                const AiDisclaimerCard(),
                const SizedBox(height: AppSpacing.md),
                SummaryNarrativeCard(texto: resumen.texto!),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'Este resumen no reemplaza las pantallas de detalle de cada '
                  'módulo.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Envuelve el contenido en un scroll con física "always" para que el
  /// pull-to-refresh funcione también con contenido corto (estados vacíos).
  Widget _scrollable(Widget child) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: child,
        ),
      ),
    );
  }
}
