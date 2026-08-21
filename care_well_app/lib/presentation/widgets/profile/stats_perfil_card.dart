import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import '../../providers/profile/stats_perfil.dart';

/// Tarjeta de cifras del perfil: personas a cargo, colaboraciones y edad.
///
/// Recibe el `AsyncValue` ya resuelto por la pantalla (presentación pura, mismo
/// criterio que `SettingsUserCard`).
///
/// La tarjeta **está siempre presente**, en cualquier estado: mientras carga,
/// ante un error o si falta un dato se pinta "—" en la casilla que corresponda.
/// Ocultarla o reemplazarla por un spinner movería el hero y los dos grupos de
/// abajo cuando el dato llega.
class StatsPerfilCard extends StatelessWidget {
  const StatsPerfilCard({super.key, required this.stats});

  /// Cifras del perfil. Se lee por `.value` (en Riverpod 3 es el getter
  /// nullable): en loading y en error queda `null` y las casillas muestran "—".
  final AsyncValue<StatsPerfil> stats;

  @override
  Widget build(BuildContext context) {
    final datos = stats.value;

    // Tres casillas en una fila no entran en un teléfono angosto a escala
    // tipográfica completa, y recortarlas dejaría las cifras ilegibles. Se
    // acota la escala sólo acá; el resto de la pantalla escala libre.
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.3,
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: AppSpacing.elev1,
        ),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Casilla(rotulo: 'A cargo', valor: datos?.aCargo),
              const _Divisor(),
              _Casilla(rotulo: 'Colaboro', valor: datos?.colaboro),
              const _Divisor(),
              _Casilla(rotulo: 'Años', valor: datos?.edad),
            ],
          ),
        ),
      ),
    );
  }
}

/// Casilla de una cifra con su rótulo. Sin dato muestra "—".
class _Casilla extends StatelessWidget {
  const _Casilla({required this.rotulo, required this.valor});

  final String rotulo;
  final int? valor;

  @override
  Widget build(BuildContext context) {
    final texto = valor?.toString() ?? '—';

    return Expanded(
      child: Semantics(
        // El lector de pantalla anuncia la casilla completa; el número suelto
        // no se entiende fuera de contexto.
        label: '$rotulo: $texto',
        child: ExcludeSemantics(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                texto,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: context.colors.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                rotulo,
                style: TextStyle(
                  fontSize: 11,
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Hilo vertical de 1 px entre casillas.
class _Divisor extends StatelessWidget {
  const _Divisor();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, color: context.colors.surfaceVariant);
  }
}
