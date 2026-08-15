import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../domain/global/tipos_habito_const.dart';

/// Tema visual (ícono y colores) asociado a un tipo de hábito de vida.
///
/// Mapea el id de catálogo del tipo ([TiposHabitoConst]) a un ícono y a un par
/// de colores (acento + contenedor) tomados de la paleta existente, de modo que
/// funcione en tema claro y oscuro sin agregar tokens nuevos. Es un helper
/// puramente presentacional: no mantiene estado ni conoce el dominio más allá
/// de los ids.
///
/// Espejo de `TipoEventoTheme` (agenda), para que ambos módulos se lean igual.
abstract final class TipoHabitoTheme {
  /// Ícono representativo del tipo con [tipoId].
  static IconData iconFor(int tipoId) => switch (tipoId) {
    TiposHabitoConst.actividadFisica => Icons.directions_run,
    TiposHabitoConst.alimentacion => Icons.restaurant,
    TiposHabitoConst.sueno => Icons.bedtime_outlined,
    TiposHabitoConst.hidratacion => Icons.water_drop_outlined,
    _ => Icons.self_improvement,
  };

  /// Color de acento (ícono/texto destacado) del tipo con [tipoId].
  static Color accentFor(BuildContext context, int tipoId) => switch (tipoId) {
    TiposHabitoConst.actividadFisica => context.colors.habitsAccent,
    TiposHabitoConst.alimentacion => context.colors.success,
    TiposHabitoConst.sueno => context.colors.moodAccent,
    TiposHabitoConst.hidratacion => context.colors.info,
    _ => context.colors.primary,
  };

  /// Color de contenedor (fondo suave) del tipo con [tipoId].
  static Color containerFor(BuildContext context, int tipoId) =>
      switch (tipoId) {
        TiposHabitoConst.actividadFisica => context.colors.habitsContainer,
        TiposHabitoConst.alimentacion => context.colors.successContainer,
        TiposHabitoConst.sueno => context.colors.moodContainer,
        TiposHabitoConst.hidratacion => context.colors.infoContainer,
        _ => context.colors.primaryContainer,
      };
}
