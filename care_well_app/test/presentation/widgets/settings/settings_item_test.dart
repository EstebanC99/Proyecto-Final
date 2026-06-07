import 'package:care_well_app/config/theme/app_colors.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SettingsItem', () {
    Widget buildItem({bool destructive = false, VoidCallback? onTap}) {
      return MaterialApp(
        home: Scaffold(
          body: SettingsItem(
            icon: Icons.person_outline,
            label: 'Mi Perfil',
            destructive: destructive,
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
      expect(text.style?.color, AppColors.error);
    });

    testWidgets('variante normal no usa color error en el texto', (
      tester,
    ) async {
      await tester.pumpWidget(buildItem(destructive: false));

      final text = tester.widget<Text>(find.text('Mi Perfil'));
      expect(text.style?.color, isNot(AppColors.error));
    });

    testWidgets('onTap se invoca al tocar', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildItem(onTap: () => tapped = true));

      await tester.tap(find.byType(SettingsItem));
      expect(tapped, isTrue);
    });
  });
}
