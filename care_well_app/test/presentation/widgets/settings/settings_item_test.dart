import 'package:care_well_app/config/theme/app_palette.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SettingsItem', () {
    Widget buildItem({
      bool destructive = false,
      VoidCallback? onTap,
      String? subtitle,
      int subtitleMaxLines = 2,
      bool showChevron = true,
      Widget? trailing,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SettingsItem(
            icon: Icons.person_outline,
            label: 'Mi Perfil',
            destructive: destructive,
            subtitle: subtitle,
            subtitleMaxLines: subtitleMaxLines,
            showChevron: showChevron,
            trailing: trailing,
            onTap: onTap ?? () {},
          ),
        ),
      );
    }

    testWidgets('muestra label e ícono', (tester) async {
      await tester.pumpWidget(buildItem());

      expect(find.text('Mi Perfil'), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('muestra chevron por defecto', (tester) async {
      await tester.pumpWidget(buildItem());

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('variante destructiva usa color error en el texto', (
      tester,
    ) async {
      await tester.pumpWidget(buildItem(destructive: true));

      final text = tester.widget<Text>(find.text('Mi Perfil'));
      expect(text.style?.color, AppPalette.light.error);
    });

    testWidgets('variante normal no usa color error en el texto', (
      tester,
    ) async {
      await tester.pumpWidget(buildItem(destructive: false));

      final text = tester.widget<Text>(find.text('Mi Perfil'));
      expect(text.style?.color, isNot(AppPalette.light.error));
    });

    testWidgets('onTap se invoca al tocar', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildItem(onTap: () => tapped = true));

      await tester.tap(find.byType(SettingsItem));
      expect(tapped, isTrue);
    });

    testWidgets('muestra el subtítulo cuando se pasa', (tester) async {
      await tester.pumpWidget(buildItem(subtitle: 'Última vez hace 3 meses'));

      expect(find.text('Última vez hace 3 meses'), findsOneWidget);
    });

    testWidgets('el subtítulo se recorta a 2 líneas por defecto', (
      tester,
    ) async {
      await tester.pumpWidget(buildItem(subtitle: 'Un texto de apoyo'));

      final texto = tester.widget<Text>(find.text('Un texto de apoyo'));
      expect(texto.maxLines, 2);
    });

    testWidgets('subtitleMaxLines controla el recorte del subtítulo', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildItem(subtitle: 'Un texto de apoyo largo', subtitleMaxLines: 3),
      );

      final texto = tester.widget<Text>(find.text('Un texto de apoyo largo'));
      expect(texto.maxLines, 3);
    });

    testWidgets('sin subtítulo solo muestra la etiqueta', (tester) async {
      await tester.pumpWidget(buildItem());

      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('showChevron false oculta el chevron', (tester) async {
      await tester.pumpWidget(buildItem(showChevron: false));

      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });

    testWidgets('trailing reemplaza al chevron', (tester) async {
      await tester.pumpWidget(
        buildItem(trailing: const Icon(Icons.open_in_new)),
      );

      expect(find.byIcon(Icons.open_in_new), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });

    testWidgets('dentro de un CardGroup sigue recibiendo el tap', (
      tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CardGroup(
              children: [
                SettingsItem(
                  icon: Icons.person_outline,
                  label: 'Mi Perfil',
                  onTap: () => tapped = true,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Mi Perfil'));
      expect(tapped, isTrue);
    });
  });
}
