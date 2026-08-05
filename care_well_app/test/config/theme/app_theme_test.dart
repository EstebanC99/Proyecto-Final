import 'package:care_well_app/config/theme/app_palette.dart';
import 'package:care_well_app/config/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final theme = AppTheme();

  group('AppTheme', () {
    test('expone un tema por brillo, cada uno con su paleta', () {
      expect(theme.light.brightness, Brightness.light);
      expect(theme.light.colorScheme.brightness, Brightness.light);
      expect(theme.light.extension<AppPalette>(), AppPalette.light);

      expect(theme.dark.brightness, Brightness.dark);
      expect(theme.dark.colorScheme.brightness, Brightness.dark);
      expect(theme.dark.extension<AppPalette>(), AppPalette.dark);
    });

    test('el ColorScheme se arma con los tokens de la paleta', () {
      for (final entry in {
        theme.light: AppPalette.light,
        theme.dark: AppPalette.dark,
      }.entries) {
        final scheme = entry.key.colorScheme;
        final palette = entry.value;

        expect(scheme.primary, palette.primary);
        expect(scheme.onPrimary, palette.onPrimary);
        expect(scheme.primaryContainer, palette.primaryContainer);
        expect(scheme.secondary, palette.secondary);
        expect(scheme.error, palette.error);
        expect(scheme.surface, palette.surface);
        expect(scheme.onSurface, palette.textPrimary);
        expect(scheme.outline, palette.outline);
        expect(entry.key.scaffoldBackgroundColor, palette.background);
      }
    });

    test('el bottom sheet usa elevación tonal en oscuro', () {
      // En claro la hoja va sobre `surface`; en oscuro se aclara a
      // `surfaceVariant` porque la sombra no se percibe (sección 8.9).
      expect(
        theme.light.bottomSheetTheme.backgroundColor,
        AppPalette.light.surface,
      );
      expect(
        theme.dark.bottomSheetTheme.backgroundColor,
        AppPalette.dark.surfaceVariant,
      );
    });

    test('el velo del bottom sheet sale de la paleta', () {
      expect(
        theme.light.bottomSheetTheme.modalBarrierColor,
        AppPalette.light.scrim,
      );
      expect(
        theme.dark.bottomSheetTheme.modalBarrierColor,
        AppPalette.dark.scrim,
      );
    });

    test('el botón primario deshabilitado cambia de criterio en oscuro', () {
      const disabled = {WidgetState.disabled};

      final darkStyle = theme.dark.filledButtonTheme.style!;
      expect(
        darkStyle.backgroundColor!.resolve(disabled),
        AppPalette.dark.surfaceVariant,
      );
      expect(
        darkStyle.foregroundColor!.resolve(disabled),
        AppPalette.dark.textDisabled,
      );

      // En claro se conserva el comportamiento por defecto de Material 3.
      final lightStyle = theme.light.filledButtonTheme.style!;
      expect(
        lightStyle.backgroundColor!.resolve(disabled),
        isNot(AppPalette.light.surfaceVariant),
      );
    });

    test('el botón primario habilitado usa el par primary/onPrimary', () {
      for (final entry in {
        theme.light.filledButtonTheme.style!: AppPalette.light,
        theme.dark.filledButtonTheme.style!: AppPalette.dark,
      }.entries) {
        expect(entry.key.backgroundColor!.resolve({}), entry.value.primary);
        expect(entry.key.foregroundColor!.resolve({}), entry.value.onPrimary);
      }
    });
  });
}
