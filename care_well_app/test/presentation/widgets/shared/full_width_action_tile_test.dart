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
  });
}
