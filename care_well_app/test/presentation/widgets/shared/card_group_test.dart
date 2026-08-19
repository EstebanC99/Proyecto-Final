import 'package:care_well_app/config/theme/app_palette.dart';
import 'package:care_well_app/config/theme/app_theme.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CardGroup', () {
    Widget wrap(Widget child, {ThemeMode themeMode = ThemeMode.light}) {
      return MaterialApp(
        themeMode: themeMode,
        theme: AppTheme().light,
        darkTheme: AppTheme().dark,
        home: Scaffold(body: child),
      );
    }

    /// Divisores internos de la tarjeta: contenedores de 1 px de alto.
    Finder divisores() => find.descendant(
      of: find.byType(CardGroup),
      matching: find.byWidgetPredicate(
        (w) => w is Container && w.constraints?.maxHeight == 1,
      ),
    );

    testWidgets('renderiza todos los hijos', (tester) async {
      await tester.pumpWidget(
        wrap(
          const CardGroup(children: [Text('Uno'), Text('Dos'), Text('Tres')]),
        ),
      );

      expect(find.text('Uno'), findsOneWidget);
      expect(find.text('Dos'), findsOneWidget);
      expect(find.text('Tres'), findsOneWidget);
    });

    testWidgets('intercala un divisor entre cada par de hijos', (tester) async {
      await tester.pumpWidget(
        wrap(
          const CardGroup(children: [Text('Uno'), Text('Dos'), Text('Tres')]),
        ),
      );

      expect(divisores(), findsNWidgets(2));
    });

    testWidgets('con un solo hijo no dibuja divisores', (tester) async {
      await tester.pumpWidget(wrap(const CardGroup(children: [Text('Uno')])));

      expect(divisores(), findsNothing);
    });

    testWidgets('sin hijos no ocupa espacio', (tester) async {
      await tester.pumpWidget(wrap(const CardGroup(children: [])));

      expect(tester.getSize(find.byType(CardGroup)), Size.zero);
    });

    testWidgets('los hijos reciben el tap (el Material interno no lo tapa)', (
      tester,
    ) async {
      var tocado = false;
      await tester.pumpWidget(
        wrap(
          CardGroup(
            children: [
              InkWell(
                onTap: () => tocado = true,
                child: const SizedBox(height: 56, child: Text('Fila')),
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Fila'));
      expect(tocado, isTrue);
    });

    testWidgets('en tema claro usa surface de fondo y surfaceVariant en el '
        'divisor', (tester) async {
      await tester.pumpWidget(
        wrap(const CardGroup(children: [Text('Uno'), Text('Dos')])),
      );

      final tarjeta = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(CardGroup),
              matching: find.byType(Container),
            )
            .first,
      );
      expect(
        (tarjeta.decoration as BoxDecoration).color,
        AppPalette.light.surface,
      );

      final divisor = tester.widget<Container>(divisores().first);
      expect(divisor.color, AppPalette.light.surfaceVariant);
    });

    testWidgets('en tema oscuro usa surface de fondo y surfaceVariant en el '
        'divisor', (tester) async {
      await tester.pumpWidget(
        wrap(
          const CardGroup(children: [Text('Uno'), Text('Dos')]),
          themeMode: ThemeMode.dark,
        ),
      );

      final tarjeta = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(CardGroup),
              matching: find.byType(Container),
            )
            .first,
      );
      expect(
        (tarjeta.decoration as BoxDecoration).color,
        AppPalette.dark.surface,
      );

      final divisor = tester.widget<Container>(divisores().first);
      expect(divisor.color, AppPalette.dark.surfaceVariant);
    });
  });
}
