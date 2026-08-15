import 'package:care_well_app/config/theme/app_palette.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

/// Decoración del contenedor animado del tile.
BoxDecoration _decoration(WidgetTester tester) {
  final container = tester.widget<AnimatedContainer>(
    find.byType(AnimatedContainer),
  );
  return container.decoration! as BoxDecoration;
}

void main() {
  const accent = Color(0xFFE11D48);

  group('FullWidthActionTile', () {
    testWidgets('por defecto es filled: rellena con el color de acento', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          FullWidthActionTile(
            icon: Icons.timeline,
            label: 'Acción',
            color: accent,
            onTap: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final decoration = _decoration(tester);
      expect(decoration.color, accent);
      expect(decoration.border, isNull);
    });

    testWidgets('outlined usa fondo de superficie y borde del acento', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          FullWidthActionTile(
            icon: Icons.timeline,
            label: 'Acción',
            color: accent,
            style: FullWidthActionTileStyle.outlined,
            onTap: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final decoration = _decoration(tester);
      expect(decoration.color, AppPalette.light.surface);
      expect(decoration.border, Border.all(color: accent, width: 1.5));
    });

    testWidgets('outlined tiñe el ícono y el texto con el color de acento', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          FullWidthActionTile(
            icon: Icons.timeline,
            label: 'Acción',
            color: accent,
            style: FullWidthActionTileStyle.outlined,
            onTap: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.widget<Icon>(find.byType(Icon)).color, accent);
      expect(tester.widget<Text>(find.text('Acción')).style?.color, accent);
    });

    testWidgets('foregroundColor explícito prevalece sobre el default', (
      tester,
    ) async {
      const tinta = Color(0xFF123456);

      await tester.pumpWidget(
        _wrap(
          FullWidthActionTile(
            icon: Icons.warning_amber_rounded,
            label: 'Acción',
            color: accent,
            foregroundColor: tinta,
            onTap: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.widget<Icon>(find.byType(Icon)).color, tinta);
      expect(tester.widget<Text>(find.text('Acción')).style?.color, tinta);
    });

    testWidgets('mide al menos 72 dp de alto', (tester) async {
      await tester.pumpWidget(
        _wrap(
          FullWidthActionTile(
            icon: Icons.timeline,
            label: 'Acción',
            color: accent,
            onTap: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getSize(find.byType(AnimatedContainer)).height,
        greaterThanOrEqualTo(72),
      );
    });

    // El tile vive en pantallas angostas (360 dp) y con tipografía ampliada:
    // el label debe ceder espacio en vez de desbordar la fila.
    for (final escala in [1.0, 1.5, 2.0]) {
      testWidgets('no desborda en 360 dp con escala $escala', (tester) async {
        tester.view.physicalSize = const Size(360, 740);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(escala)),
              child: Scaffold(
                body: Padding(
                  padding: const EdgeInsets.all(16),
                  child: FullWidthActionTile(
                    icon: Icons.timeline,
                    label: 'Ver línea de tiempo',
                    color: accent,
                    onTap: () {},
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });
    }
  });
}
