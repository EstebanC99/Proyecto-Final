import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import 'context_selector.dart';
import 'context_selector_compact.dart';

/// AppBar contextual: fusiona el rótulo de la sección con el selector de
/// persona de contexto.
///
/// Reemplaza al par "título plano en el AppBar + [ContextSelector] repitiendo
/// el mismo texto en el body" que tenían las pantallas de nivel 1. La fila del
/// título es un [ContextSelector] en la variante
/// [ContextSelectorVariant.appBar]: avatar con anillo, rótulo en versales,
/// nombre, badge de rol abreviado y chevron cuando hay más de una persona
/// seleccionable (al tocarlo abre el bottom sheet "Visualizando a").
///
/// No expone la persona ni el rol: el selector los resuelve por su cuenta
/// desde Riverpod. La pantalla solo aporta el rótulo y sus acciones.
///
/// ## Alto
/// El contenido del título son dos líneas de texto que crecen con la escala
/// tipográfica del sistema, así que el toolbar no puede quedar fijo en 56dp:
/// el alto se calcula en [alturaPara] y se aplica vía `AppBar.toolbarHeight`.
///
/// `Scaffold` limita la barra a `preferredSize.height` y el `AppBar` ocupa
/// exactamente ese alto, así que [preferredSize] y `toolbarHeight` tienen que
/// coincidir: declarar de menos recorta la barra y declarar de más deja una
/// franja vacía. Como [preferredSize] no recibe un `BuildContext`, la escala
/// se lee del [PlatformDispatcher] —la misma fuente de la que `MediaQuery`
/// deriva su `textScaler` en la app— en lugar de `MediaQuery.textScalerOf`.
/// Consecuencia: un `MediaQuery` local que sobreescriba el `textScaler` solo
/// para una parte del árbol no afecta al alto de la barra.
class ContextAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ContextAppBar({
    super.key,
    required this.eyebrow,
    this.actions = const [],
    this.backgroundColor,
    this.foregroundColor,
    this.bottom,
    this.seleccionable = true,
  });

  /// Rótulo de la sección, en versales ("Calendario", "Salud", ...).
  final String eyebrow;

  /// Acciones propias de la pantalla, a la derecha del título.
  final List<Widget> actions;

  /// Fondo de la barra. Por defecto `surface`.
  final Color? backgroundColor;

  /// Color de íconos y texto propios del AppBar (la flecha de "atrás" y las
  /// acciones). Por defecto `textPrimary`.
  ///
  /// No afecta al rótulo ni al nombre del selector, que se pintan siempre con
  /// los colores de texto del tema.
  final Color? foregroundColor;

  /// Widget al pie de la barra (por ejemplo, un borde de 1dp).
  final PreferredSizeWidget? bottom;

  /// Habilita el cambio de persona de contexto desde la barra. En `false` el
  /// selector se ve igual pero no reacciona al toque; lo usan los formularios,
  /// donde cambiar de persona a mitad de la carga confundiría el destino de
  /// los datos ya escritos.
  final bool seleccionable;

  /// Alto del toolbar para una escala tipográfica dada.
  ///
  /// Dos líneas (rótulo + nombre) más su separación, con un piso en el área
  /// táctil mínima —el avatar con anillo ya mide 48dp— y un colchón de 8dp
  /// para que el texto no toque los bordes. Nunca por debajo del alto
  /// estándar de un AppBar.
  static double alturaPara(TextScaler escala) {
    final textos =
        escala.scale(ContextCompactBanner.eyebrowFontSize) *
            ContextCompactBanner.alturaLinea +
        ContextCompactBanner.gapTextos +
        escala.scale(ContextCompactBanner.nombreFontSize) *
            ContextCompactBanner.alturaLinea;
    return math.max(
      AppSpacing.appBarHeight,
      math.max(AppSpacing.minTapTarget, textos) + AppSpacing.sm,
    );
  }

  /// Alto del toolbar con la escala tipográfica configurada en el sistema.
  static double get alturaActual => alturaPara(
    TextScaler.linear(
      WidgetsBinding.instance.platformDispatcher.textScaleFactor,
    ),
  );

  @override
  Size get preferredSize =>
      Size.fromHeight(alturaActual + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? context.colors.surface,
      foregroundColor: foregroundColor ?? context.colors.textPrimary,
      elevation: 0,
      toolbarHeight: alturaActual,
      // El banner arranca pegado al botón de "atrás"; el aire de la derecha lo
      // pone el Padding, que no depende de si hay acciones o no.
      titleSpacing: 0,
      title: MergeSemantics(
        // El título del AppBar es el header de la pantalla para el lector de
        // pantalla; al pasar de un Text a una fila compuesta hay que
        // declararlo explícitamente.
        child: Semantics(
          header: true,
          child: Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: ContextSelector(
              variant: ContextSelectorVariant.appBar,
              eyebrow: eyebrow,
              seleccionable: seleccionable,
            ),
          ),
        ),
      ),
      actions: actions,
      bottom: bottom,
    );
  }
}
