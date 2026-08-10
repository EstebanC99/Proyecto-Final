import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routers/app_routes.dart';
import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

/// Pantalla raíz post-login: menú principal de CareWell.
///
/// Muestra el header, el selector de contexto, el grid 2×2 de secciones
/// y el tile de emergencia siempre visible.
/// El tile de "Personas a cargo" alterna entre skeleton, empty state y tile
/// normal según el estado de [allActiveAssignmentsProvider].
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final usuario = authState.value;
    final userName = usuario?.persona.nombre ?? '';

    final dependentsAsync = ref.watch(asignacionesActivasProvider);
    final animoHoyAsync = ref.watch(animoHoyProvider);
    // Solo se toma el ánimo de un estado recién resuelto (AsyncData). Durante
    // loading/error se trata como "sin dato" para evitar que el badge quede
    // pegado con el emoji de la persona anterior al cambiar el contexto.
    final animoHoy = switch (animoHoyAsync) {
      AsyncData(:final value) => value,
      _ => null,
    };

    // Badge de estado de ánimo para el NavTile de Salud.
    // Siempre visible: muestra el emoji si hay ánimo registrado hoy, o '?' si no.
    final Widget animoBadge = Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: context.colors.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: animoHoy != null
              ? moodLevelColor(context.colors, moodLevel(animoHoy.estado))
              : context.colors.textDisabled,
          width: 2,
        ),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Center(
        child: Text(
          animoHoy != null ? moodEmoji(animoHoy.estado) : '?',
          style: TextStyle(
            fontSize: 12,
            color: animoHoy != null ? null : context.colors.textDisabled,
            fontWeight: animoHoy != null ? null : FontWeight.bold,
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: context.colors.background,
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _showExitDialog(context);
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                HomeHeader(
                  userName: userName,
                  personaId: usuario?.persona.id,
                  onTapProfile: () => context.pushNamed(AppRoutes.settingsName),
                ),
                const SizedBox(height: AppSpacing.md),

                // Selector de persona de contexto global
                const ContextSelector(variant: ContextSelectorVariant.compact),
                const SizedBox(height: AppSpacing.md),

                // Acceso al Resumen inteligente (estático: no dispara la IA).
                //
                // El texto es de relleno: el hero todavía no está conectado al
                // provider de IA. Cuando se conecte, solo cambia el `state`
                // que se le pasa acá; el widget no se toca.
                SummaryHeroCard(
                  delay: const Duration(milliseconds: 50),
                  state: const SummaryHeroContent(
                    texto:
                        'Acá va un texto breve acorde al resumen diario '
                        'generado.',
                  ),
                  onTapVerCompleto: () =>
                      context.pushNamed(AppRoutes.summaryName),
                ),
                const SizedBox(height: AppSpacing.md),

                // Grid 2×2.
                //
                // Se arma con dos filas en IntrinsicHeight en lugar de un
                // GridView de celdas cuadradas: la altura la define el
                // contenido más alto de cada fila, así la descripción de dos
                // líneas no desborda con escalas de fuente grandes.
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Calendario
                      Expanded(
                        child: NavTile(
                          icon: Icons.calendar_month,
                          label: 'Calendario',
                          description: 'Turnos y eventos',
                          accentColor: context.colors.calendarAccent,
                          delay: Duration.zero,
                          onTap: () => context.pushNamed(AppRoutes.agendaName),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),

                      // Equipo de cuidado
                      Expanded(
                        child: NavTile(
                          icon: Icons.groups,
                          label: 'Equipo de cuidado',
                          description: 'Quién ayuda y cómo',
                          accentColor: context.colors.careTeamAccent,
                          delay: const Duration(milliseconds: 100),
                          onTap: () =>
                              context.pushNamed(AppRoutes.careTeamName),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Personas a cargo — dinámico
                      Expanded(
                        child: _buildDependentsTile(
                          context,
                          ref,
                          dependentsAsync,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),

                      // Salud
                      Expanded(
                        child: NavTile(
                          icon: Icons.favorite,
                          label: 'Salud',
                          description: 'Registros y estado',
                          accentColor: context.colors.healthAccent,
                          delay: const Duration(milliseconds: 300),
                          badge: animoBadge,
                          onTap: () => context.pushNamed(AppRoutes.healthName),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Tile de emergencia: siempre visible
                EmergencyTile(
                  delay: const Duration(milliseconds: 400),
                  onTap: () => context.pushNamed(AppRoutes.emergencyName),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Construye el tile de personas a cargo según el estado del provider.
  Widget _buildDependentsTile(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<AsignacionCuidado>> dependentsAsync,
  ) {
    return dependentsAsync.when(
      loading: () => const NavTileSkeleton(),
      error: (e, st) => NavTile(
        icon: Icons.error_outline,
        label: 'Personas a cargo',
        description: 'Perfiles que cuidás',
        accentColor: context.colors.dependentsAccent,
        delay: const Duration(milliseconds: 200),
        onTap: () => context.pushNamed(AppRoutes.dependentsName),
      ),
      data: (list) {
        if (list.isEmpty) {
          return EmptyStateTile(
            accentColor: context.colors.dependentsAccent,
            onTap: () => context.pushNamed(AppRoutes.dependentsName),
            onTapAdd: () => context.pushNamed(AppRoutes.dependentsNewName),
          );
        }
        return NavTile(
          icon: Icons.elderly,
          label: 'Personas a cargo',
          description: 'Perfiles que cuidás',
          accentColor: context.colors.dependentsAccent,
          delay: const Duration(milliseconds: 200),
          onTap: () => context.pushNamed(AppRoutes.dependentsName),
        );
      },
    );
  }

  /// Muestra el diálogo de confirmación de salida de la app.
  void _showExitDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Salir de CareWell?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: SystemNavigator.pop,
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }
}
