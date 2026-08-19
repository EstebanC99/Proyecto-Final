import 'package:care_well_app/config/theme/app_palette.dart';
import 'package:care_well_app/config/theme/app_theme.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IconSquare', () {
    Widget wrap(Widget child, {ThemeMode themeMode = ThemeMode.light}) {
      return MaterialApp(
        themeMode: themeMode,
        theme: AppTheme().light,
        darkTheme: AppTheme().dark,
        home: Scaffold(body: child),
      );
    }

    testWidgets('muestra el ícono con el tamaño por defecto', (tester) async {
      await tester.pumpWidget(wrap(const IconSquare(icon: Icons.person)));

      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(tester.getSize(find.byType(IconSquare)), const Size(38, 38));
    });

    testWidgets('por defecto usa el tinte de marca', (tester) async {
      await tester.pumpWidget(wrap(const IconSquare(icon: Icons.person)));

      final icono = tester.widget<Icon>(find.byIcon(Icons.person));
      expect(icono.color, AppPalette.light.primary);

      final cuadrado = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(IconSquare),
              matching: find.byType(Container),
            )
            .first,
      );
      expect(
        (cuadrado.decoration as BoxDecoration).color,
        AppPalette.light.primaryContainer,
      );
    });

    testWidgets('respeta color y background explícitos', (tester) async {
      await tester.pumpWidget(
        wrap(
          IconSquare(
            icon: Icons.delete_forever_outlined,
            color: AppPalette.light.error,
            background: AppPalette.light.errorContainer,
          ),
        ),
      );

      final icono = tester.widget<Icon>(
        find.byIcon(Icons.delete_forever_outlined),
      );
      expect(icono.color, AppPalette.light.error);

      final cuadrado = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(IconSquare),
              matching: find.byType(Container),
            )
            .first,
      );
      expect(
        (cuadrado.decoration as BoxDecoration).color,
        AppPalette.light.errorContainer,
      );
    });

    testWidgets('respeta size e iconSize personalizados', (tester) async {
      await tester.pumpWidget(
        wrap(const IconSquare(icon: Icons.person, size: 48, iconSize: 24)),
      );

      expect(tester.getSize(find.byType(IconSquare)), const Size(48, 48));
      expect(tester.widget<Icon>(find.byIcon(Icons.person)).size, 24);
    });

    testWidgets('en tema oscuro resuelve el tinte contra la paleta oscura', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(const IconSquare(icon: Icons.person), themeMode: ThemeMode.dark),
      );

      final icono = tester.widget<Icon>(find.byIcon(Icons.person));
      expect(icono.color, AppPalette.dark.primary);
    });

    testWidgets('es decorativo: no aporta semántica', (tester) async {
      await tester.pumpWidget(wrap(const IconSquare(icon: Icons.person)));

      // El cuadrado completo (fondo + ícono) queda fuera del árbol semántico.
      final exclusion = tester.widget<ExcludeSemantics>(
        find
            .descendant(
              of: find.byType(IconSquare),
              matching: find.byType(ExcludeSemantics),
            )
            .first,
      );
      expect(exclusion.excluding, isTrue);
      expect(
        find.descendant(
          of: find.byWidget(exclusion),
          matching: find.byIcon(Icons.person),
        ),
        findsOneWidget,
      );
    });
  });
}
