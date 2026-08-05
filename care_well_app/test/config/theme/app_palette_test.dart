import 'dart:math' as math;

import 'package:care_well_app/config/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Luminancia relativa de un color, según WCAG 2.x.
double _luminance(Color c) {
  double channel(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();

  return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
}

/// Ratio de contraste entre dos colores opacos, según WCAG 2.x.
double _contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  group('AppPalette', () {
    test('claro y oscuro no comparten los tonos de marca ni los neutros', () {
      const light = AppPalette.light;
      const dark = AppPalette.dark;

      expect(dark.primary, isNot(light.primary));
      expect(dark.secondary, isNot(light.secondary));
      expect(dark.background, isNot(light.background));
      expect(dark.surface, isNot(light.surface));
      expect(dark.textPrimary, isNot(light.textPrimary));
      expect(dark.error, isNot(light.error));
    });

    test('en oscuro las superficies se aclaran con la elevación tonal', () {
      const dark = AppPalette.dark;

      // background < surface < surfaceVariant: a más elevación, más clara la
      // superficie (sección 8.9). En claro la dirección es la inversa.
      expect(_luminance(dark.background), lessThan(_luminance(dark.surface)));
      expect(
        _luminance(dark.surface),
        lessThan(_luminance(dark.surfaceVariant)),
      );
      expect(
        _luminance(AppPalette.light.surface),
        greaterThan(_luminance(AppPalette.light.surfaceVariant)),
      );
    });

    test('en oscuro no se usan negro ni blanco puros', () {
      const dark = AppPalette.dark;

      expect(dark.background, isNot(const Color(0xFF000000)));
      expect(dark.surface, isNot(const Color(0xFF000000)));
      expect(dark.textPrimary, isNot(const Color(0xFFFFFFFF)));
    });

    test('el pressed de emergencia se aleja del reposo en cada tema', () {
      // En claro el relleno se oscurece; en oscuro se aclara, porque ahí la
      // tinta es oscura y oscurecer el fondo restaría contraste en vez de dar
      // feedback. Lo que importa es que haya salto perceptible, no la dirección.
      expect(
        _luminance(AppPalette.light.emergencyRedPressed),
        lessThan(_luminance(AppPalette.light.emergencyRed)),
      );
      expect(
        _luminance(AppPalette.dark.emergencyRedPressed),
        greaterThan(_luminance(AppPalette.dark.emergencyRed)),
      );
    });

    test('el velo y el blob de ánimo suben de intensidad en oscuro', () {
      expect(
        AppPalette.dark.moodBlobAlpha,
        greaterThan(AppPalette.light.moodBlobAlpha),
      );
      expect(AppPalette.dark.scrim.a, greaterThan(AppPalette.light.scrim.a));
    });

    group('contraste WCAG', () {
      for (final entry in {
        'claro': AppPalette.light,
        'oscuro': AppPalette.dark,
      }.entries) {
        final name = entry.key;
        final palette = entry.value;

        test('$name: el texto cumple los mínimos de legibilidad', () {
          // Texto principal: AAA sobre fondo y sobre tarjeta.
          expect(
            _contrast(palette.textPrimary, palette.background),
            greaterThanOrEqualTo(7),
          );
          expect(
            _contrast(palette.textPrimary, palette.surface),
            greaterThanOrEqualTo(7),
          );
          // Texto secundario: AA de texto normal.
          expect(
            _contrast(palette.textSecondary, palette.surface),
            greaterThanOrEqualTo(4.5),
          );
          // Mensajes de error sobre tarjeta.
          expect(
            _contrast(palette.error, palette.surface),
            greaterThanOrEqualTo(4.5),
          );
        });
      }

      test('oscuro: los rellenos de color admiten texto normal (AA)', () {
        const dark = AppPalette.dark;

        // Al aclararse el primario y el secundario, el texto encima pasa a ser
        // oscuro y gana contraste respecto del tema claro (sección 8.8).
        expect(
          _contrast(dark.onPrimary, dark.primary),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          _contrast(dark.onSecondary, dark.secondary),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          _contrast(dark.onPrimary, dark.primary),
          greaterThan(
            _contrast(AppPalette.light.onPrimary, AppPalette.light.primary),
          ),
        );
      });

      test('oscuro: los semánticos son legibles sobre la tarjeta', () {
        const dark = AppPalette.dark;

        for (final color in [dark.success, dark.warning, dark.info]) {
          expect(_contrast(color, dark.surface), greaterThanOrEqualTo(4.5));
        }
      });

      test('la tinta de emergencia es legible sobre sus dos rellenos', () {
        // onPrimary no sirve acá: en oscuro emergencyRed es un rojo claro y el
        // blanco encima queda en 3.03:1.
        for (final palette in [AppPalette.light, AppPalette.dark]) {
          expect(
            _contrast(palette.onEmergency, palette.emergencyRed),
            greaterThanOrEqualTo(4.5),
          );
          expect(
            _contrast(palette.onEmergency, palette.emergencyRedPressed),
            greaterThanOrEqualTo(4.5),
          );
        }
      });

      test('oscuro: el deshabilitado cumple el 3:1 de componentes UI', () {
        // Exento del mínimo de texto, pero debe delimitar controles (1.4.11).
        expect(
          _contrast(AppPalette.dark.textDisabled, AppPalette.dark.surface),
          greaterThanOrEqualTo(3),
        );
      });
    });

    test('lerp interpola entre ambas variantes', () {
      const light = AppPalette.light;
      const dark = AppPalette.dark;

      expect(light.lerp(dark, 0).primary, light.primary);
      expect(light.lerp(dark, 1).primary, dark.primary);
      expect(light.lerp(dark, 1).moodBlobAlpha, dark.moodBlobAlpha);
      expect(light.lerp(null, 1), same(light));
    });

    test('copyWith solo reemplaza los tokens indicados', () {
      const original = AppPalette.light;
      final copia = original.copyWith(primary: const Color(0xFF123456));

      expect(copia.primary, const Color(0xFF123456));
      expect(copia.textPrimary, original.textPrimary);
      expect(copia.scrim, original.scrim);
    });
  });

  group('context.colors', () {
    testWidgets('resuelve la paleta del tema vigente', (tester) async {
      late AppPalette resuelta;

      Widget app(ThemeData theme) => MaterialApp(
        theme: theme,
        home: Builder(
          builder: (context) {
            resuelta = context.colors;
            return const SizedBox.shrink();
          },
        ),
      );

      await tester.pumpWidget(
        app(ThemeData(extensions: const [AppPalette.dark])),
      );
      expect(resuelta.primary, AppPalette.dark.primary);

      // El cambio de tema se anima: hay que dejar que la transición termine
      // para leer la paleta destino (así se comporta al cambiar el modo del SO).
      await tester.pumpWidget(
        app(ThemeData(extensions: const [AppPalette.light])),
      );
      await tester.pumpAndSettle();
      expect(resuelta.primary, AppPalette.light.primary);
    });

    testWidgets('cae al tema claro si la extensión no está registrada', (
      tester,
    ) async {
      late AppPalette resuelta;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              resuelta = context.colors;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(resuelta.primary, AppPalette.light.primary);
    });
  });
}
