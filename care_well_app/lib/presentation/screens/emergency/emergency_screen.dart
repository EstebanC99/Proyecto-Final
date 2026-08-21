import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routers/app_routes.dart';
import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

/// Pantalla principal de emergencia (US-34).
///
/// Muestra el [EmergencyButton] pulsante y la lista del equipo de cuidado.
/// Requiere confirmación via [EmergencyConfirmDialog] antes de activar.
class EmergencyScreen extends ConsumerWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final equipoAsync = ref.watch(equipoEmergenciaProvider);
    final puedeAsync = ref.watch(puedeActivarEmergenciaProvider);

    final puede = puedeAsync.value ?? false;

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: ContextAppBar(
        eyebrow: 'Emergencia',
        // El rojo queda en la flecha de "atrás" y en el borde inferior: el
        // rótulo y el nombre del selector usan siempre los colores de texto
        // del tema, como en el resto de las pantallas.
        foregroundColor: context.colors.emergencyRed,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: context.colors.outline),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [context.colors.emergencyContainer, context.colors.surface],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xl),

              // Texto explicativo
              Text(
                'Al activar la emergencia, se enviará un aviso inmediato '
                'a tu equipo de cuidado.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Card del equipo de cuidado
              equipoAsync.when(
                loading: () => Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: context.colors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
                error: (err, _) => InlineErrorBanner(
                  message: 'No se pudo cargar el equipo. $err',
                ),
                data: (miembros) => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    boxShadow: AppSpacing.elev1,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.groups,
                            size: 20,
                            color: context.colors.emergencyRed,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            miembros.isEmpty
                                ? 'Sin miembros en el equipo'
                                : 'Equipo de cuidado',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: context.colors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      if (miembros.isNotEmpty) ...[
                        const Divider(height: AppSpacing.lg),
                        ...miembros.map(
                          (m) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.person,
                                  size: 16,
                                  color: context.colors.textSecondary,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Text(
                                    '${m.colaborador.nombre} ${m.colaborador.apellido}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: context.colors.textPrimary,
                                    ),
                                  ),
                                ),
                                Text(
                                  m.rol.id == RolesCuidadoConst.responsable
                                      ? '(Responsable)'
                                      : '(Cuidador/a)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: context.colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Zona del botón de emergencia
              Tooltip(
                message: puede
                    ? ''
                    : 'No tenés permiso para activar emergencias',
                child: EmergencyButton(
                  enabled: puede && (equipoAsync.value?.isNotEmpty ?? false),
                  onTap: () => _handleTap(context, ref),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Tocá el botón para enviar la alerta',
                style: TextStyle(
                  fontSize: 13,
                  color: context.colors.textDisabled,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Historial corto. Va DEBAJO del botón a propósito: arriba lo
              // desplazaría según cuántas emergencias haya, o sea que el
              // control más importante de la pantalla cambiaría de lugar
              // según los datos.
              ref
                  .watch(historialEmergenciasProvider)
                  .when(
                    // Sin spinner: el historial es accesorio y no debe competir
                    // con el botón.
                    loading: () => const SizedBox.shrink(),
                    // Silencioso: si el historial falla, la pantalla igual tiene
                    // que servir para activar la emergencia. Nunca un error acá.
                    error: (_, _) => const SizedBox.shrink(),
                    data: (emergencias) =>
                        _HistorialCard(emergencias: emergencias),
                  ),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleTap(BuildContext context, WidgetRef ref) async {
    final persona = ref.read(personaVisualizacionSeleccionadaProvider).value;
    if (persona == null) return;

    final confirmo = await EmergencyConfirmDialog.show(
      context,
      nombrePersona: persona.nombre,
      onConfirm: () async {
        await ref.read(activarEmergenciaProvider)();
      },
    );

    if (confirmo == true && context.mounted) {
      // `pushReplacement` y no `go`: reemplaza esta pantalla por la de
      // confirmación —que no se pueda volver al botón es intencional
      // (anti-reenvío)— sin destruir las páginas de abajo, así el back del
      // sistema sigue teniendo a dónde volver.
      context.pushReplacementNamed(AppRoutes.emergencySentName);
    }
  }
}

/// Card del historial corto de emergencias de la persona de contexto.
///
/// El caso vacío SÍ se muestra: "no hay emergencias registradas" es una
/// respuesta exitosa, y además es información tranquilizadora. Loading y error
/// no son respuestas —son estados donde el cliente no sabe nada— y ahí el
/// silencio es mejor que el ruido.
class _HistorialCard extends StatelessWidget {
  const _HistorialCard({required this.emergencias});

  final List<Emergencia> emergencias;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: AppSpacing.elev1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history,
                size: 20,
                color: context.colors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Últimas emergencias',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: context.colors.textPrimary,
                ),
              ),
            ],
          ),
          if (emergencias.isEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Sin emergencias registradas',
              style: TextStyle(
                fontSize: 13,
                color: context.colors.textSecondary,
              ),
            ),
          ] else ...[
            const Divider(height: AppSpacing.lg),
            for (int i = 0; i < emergencias.length; i++) ...[
              EmergencyHistoryTile(emergencia: emergencias[i]),
              if (i < emergencias.length - 1)
                Divider(height: 1, color: context.colors.surfaceVariant),
            ],
          ],
        ],
      ),
    );
  }
}
