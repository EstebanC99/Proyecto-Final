import 'package:flutter/material.dart';

import 'app_palette.dart';
import 'app_spacing.dart';

/// Construye los [ThemeData] de la app a partir de una [AppPalette].
///
/// Ambos temas comparten la misma definición de componentes: lo único que
/// cambia es la paleta de tokens y el [Brightness]. El tema oscuro no es
/// seleccionable dentro de la app; se activa desde el sistema operativo
/// (`ThemeMode.system` en el `MaterialApp`).
class AppTheme {
  /// Tema claro (sección 2 del spec de identidad visual).
  ThemeData get light => _build(AppPalette.light, Brightness.light);

  /// Tema oscuro (sección 8 del spec de identidad visual).
  ThemeData get dark => _build(AppPalette.dark, Brightness.dark);

  ThemeData _build(AppPalette palette, Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: palette.primary,
        onPrimary: palette.onPrimary,
        primaryContainer: palette.primaryContainer,
        onPrimaryContainer: palette.onPrimaryContainer,
        secondary: palette.secondary,
        onSecondary: palette.onSecondary,
        secondaryContainer: palette.secondaryContainer,
        onSecondaryContainer: palette.textPrimary,
        error: palette.error,
        onError: palette.onPrimary,
        errorContainer: palette.errorContainer,
        onErrorContainer: palette.error,
        surface: palette.surface,
        onSurface: palette.textPrimary,
        surfaceContainerHighest: palette.surfaceVariant,
        onSurfaceVariant: palette.textSecondary,
        outline: palette.outline,
        outlineVariant: palette.outlineStrong,
        scrim: palette.scrim,
      ),
      extensions: [palette],
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        hintStyle: TextStyle(color: palette.textDisabled),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: palette.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: palette.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: palette.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: palette.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: palette.error, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: palette.onPrimary,
          // En oscuro, rellenar el botón deshabilitado con un gris claro se ve
          // fuera de lugar: se usa una superficie oscura neutra + texto tenue
          // (sección 8.10). En claro se conserva el default de Material 3.
          disabledBackgroundColor: isDark ? palette.surfaceVariant : null,
          disabledForegroundColor: isDark ? palette.textDisabled : null,
          minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? palette.primary : null,
        ),
        checkColor: WidgetStatePropertyAll(palette.onPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        // Elevación tonal en oscuro: la hoja se separa del fondo con una
        // superficie más clara en vez de una sombra (sección 8.9).
        backgroundColor: isDark ? palette.surfaceVariant : palette.surface,
        modalBackgroundColor: isDark ? palette.surfaceVariant : palette.surface,
        modalBarrierColor: palette.scrim,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXl),
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        foregroundColor: palette.textPrimary,
        elevation: 0,
        // En oscuro la sombra no se percibe: al hacer scroll la barra se aclara
        // por elevación tonal en vez de proyectar sombra (sección 8.9).
        scrolledUnderElevation: isDark ? 3 : 1,
        surfaceTintColor: isDark ? palette.primary : null,
        centerTitle: false,
      ),
      scaffoldBackgroundColor: palette.background,
      fontFamily: 'Inter',
    );
  }
}
