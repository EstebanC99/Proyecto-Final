import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/exceptions/exceptions.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

/// Pantalla de Resumen inteligente (US 9.16).
///
/// Muestra el resumen del día de la persona de contexto: se pide al abrirse y
/// al cambiar de persona (el provider observa
/// [personaVisualizacionSeleccionadaProvider]), reutilizando el que el backend
/// tenga vigente. El botón de la AppBar y el pull-to-refresh sí fuerzan una
/// regeneración real contra el modelo de IA con
/// [SummaryNotifier.refrescar]; el "Reintentar" del banner de error, en
/// cambio, sólo vuelve a consultar: si hay un resumen vigente corresponde
/// mostrarlo en vez de gastar otra inferencia.
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
      backgroundColor: context.colors.background,
      appBar: ContextAppBar(
        eyebrow: 'Resumen',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: cargando
                ? null
                : () =>
                      ref.read(resumenInteligenteProvider.notifier).refrescar(),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                // Guard equivalente al del botón "Actualizar": si ya hay una
                // generación en curso no se pide otra (desperdiciaría una
                // inferencia de IA en CPU). Igual se espera al future en curso
                // para que el spinner del pull acompañe a la generación y el
                // usuario tenga feedback.
                if (ref.read(resumenInteligenteProvider).isLoading) {
                  // La falla ya la pinta el banner de error de esta pantalla:
                  // acá sólo interesa saber cuándo terminó, para cerrar el
                  // indicador del pull.
                  try {
                    await ref.read(resumenInteligenteProvider.future);
                  } catch (_) {}
                  return;
                }
                await ref.read(resumenInteligenteProvider.notifier).refrescar();
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
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Text(
              'Primero agregá una persona a cargo para ver el resumen.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: context.colors.textSecondary,
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
      // El `Align` afloja el `minHeight` que impone `_scrollable`: sin él, el
      // banner —que no tiene alto propio— se estira a la pantalla completa.
      error: (err, _) => _scrollable(
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: InlineErrorBanner(
              message: _mensajeDeError(err),
              actionLabel: 'Reintentar',
              onAction: () => ref.invalidate(resumenInteligenteProvider),
            ),
          ),
        ),
      ),
      data: (resumen) {
        // Sin persona (resuelto): estado ya cubierto arriba salvo carreras.
        if (resumen == null) {
          return _scrollable(const SizedBox.shrink());
        }

        // Éxito sin nada que pintar: empty state neutro. Se decide por
        // `hayContenidoVisible` y no por `tieneDatos`, porque el backend puede
        // informar datos que esta pantalla no muestra (p. ej. solo el
        // `resumenAcotado`, que alimenta el hero del Home).
        if (!resumen.hayContenidoVisible) {
          return _scrollable(
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
              child: SummaryEmptyState(),
            ),
          );
        }

        // Éxito con datos: cada sección se pinta solo si tiene contenido, con
        // la entrada escalonada del mockup (60/130/200/270 ms).
        return _scrollable(
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SummaryDayBand(
                  fecha: resumen.generadoEn ?? DateTime.now(),
                  estadoAnimo: resumen.estadoAnimo,
                  generadoEn: resumen.generadoEn,
                ),
                if (resumen.hayHabitos) ...[
                  const SizedBox(height: AppSpacing.md),
                  SummaryHabitsCard(
                    habitos: resumen.habitos,
                    completados: resumen.habitosCompletados,
                    progreso: resumen.progresoHabitos,
                    resumen: resumen.resumenHabitos,
                    delay: const Duration(milliseconds: 60),
                  ),
                ],
                if (resumen.eventosSalud.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  SummaryHealthTimelineCard(
                    eventos: resumen.eventosSalud,
                    delay: const Duration(milliseconds: 130),
                  ),
                ],
                if (resumen.hayAtencion) ...[
                  const SizedBox(height: AppSpacing.md),
                  SummaryAttentionCard(
                    recomendaciones: resumen.recomendaciones,
                    recordatoriosHoy: resumen.recordatoriosHoy,
                    delay: const Duration(milliseconds: 200),
                  ),
                ],
                if (resumen.hayManana) ...[
                  const SizedBox(height: AppSpacing.md),
                  SummaryTomorrowCard(
                    recordatorios: resumen.recordatoriosManana,
                    habitos: resumen.habitosManana,
                    delay: const Duration(milliseconds: 270),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                const SummaryFooterDisclaimer(),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Texto del banner de error, siempre redactado para el usuario.
  ///
  /// Las excepciones de dominio ya traen un mensaje pensado para mostrar, así
  /// que se usa tal cual. Cualquier otra falla (un error de parseo, un bug) se
  /// resume en una frase genérica: volcar su `toString()` llenaría la pantalla
  /// de detalle técnico. El error completo sigue quedando en el log de Riverpod.
  String _mensajeDeError(Object err) {
    if (err is SinConexionException ||
        err is ServicioNoDisponibleException ||
        err is ServidorException) {
      return err.toString();
    }
    return 'No se pudo generar el resumen. Intentá de nuevo en unos minutos.';
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
