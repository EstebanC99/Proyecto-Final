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

  // Colores de acento para cada NavTile — basados en imagen del diseñador
  static const Color _calendarColor = Color(0xFF4A90D9); // azul medio
  static const Color _careTeamColor = Color(0xFFF5A623); // ámbar/amarillo
  static const Color _dependentsColor = Color(0xFFF07844); // naranja
  static const Color _healthColor = Color(0xFFE05C8A); // rosa/rojo

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
                const ContextSelector(),
                const SizedBox(height: AppSpacing.md),

                // Acceso al Resumen inteligente (estático: no dispara la IA)
                const SummaryEntryCard(delay: Duration(milliseconds: 50)),
                const SizedBox(height: AppSpacing.md),

                // Grid 2×2
                GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                  ),
                  children: [
                    // Calendario
                    NavTile(
                      icon: Icons.calendar_month,
                      label: 'Calendario',
                      accentColor: _calendarColor,
                      delay: Duration.zero,
                      onTap: () => context.pushNamed(AppRoutes.agendaName),
                    ),

                    // Equipo de cuidado
                    NavTile(
                      icon: Icons.groups,
                      label: 'Equipo de cuidado',
                      accentColor: _careTeamColor,
                      delay: const Duration(milliseconds: 100),
                      onTap: () => context.pushNamed(AppRoutes.careTeamName),
                    ),

                    // Personas a cargo — dinámico
                    _buildDependentsTile(context, ref, dependentsAsync),

                    // Salud
                    NavTile(
                      icon: Icons.favorite,
                      label: 'Salud',
                      accentColor: _healthColor,
                      delay: const Duration(milliseconds: 300),
                      badge: animoBadge,
                      onTap: () => context.pushNamed(AppRoutes.healthName),
                    ),
                  ],
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
        accentColor: _dependentsColor,
        delay: const Duration(milliseconds: 200),
        onTap: () => context.pushNamed(AppRoutes.dependentsName),
      ),
      data: (list) {
        if (list.isEmpty) {
          return EmptyStateTile(
            accentColor: _dependentsColor,
            onTap: () => context.pushNamed(AppRoutes.dependentsName),
            onTapAdd: () => context.pushNamed(AppRoutes.dependentsNewName),
          );
        }
        return NavTile(
          icon: Icons.elderly,
          label: 'Personas a cargo',
          accentColor: _dependentsColor,
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
