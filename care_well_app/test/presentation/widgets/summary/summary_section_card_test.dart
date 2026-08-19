import 'package:care_well_app/config/theme/app_palette.dart';
import 'package:care_well_app/config/theme/app_theme.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap({bool disableAnimations = false, VoidCallback? onTapHeader}) {
    return MaterialApp(
      theme: AppTheme().light,
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(disableAnimations: disableAnimations),
          child: Scaffold(
            body: SummarySectionCard(
              icon: Icons.favorite,
              iconColor: AppPalette.light.healthAccent,
              iconBackgroundColor: AppPalette.light.healthContainer,
              title: 'Hábitos del día',
              meta: '4 de 6',
              onTapHeader: onTapHeader,
              expandido: onTapHeader == null ? null : false,
              child: const Text('Contenido de la sección'),
            ),
          ),
        ),
      ),
    );
  }

  group('SummarySectionCard', () {
    testWidgets('muestra encabezado, meta y contenido', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      expect(find.text('Hábitos del día'), findsOneWidget);
      expect(find.text('4 de 6'), findsOneWidget);
      expect(find.text('Contenido de la sección'), findsOneWidget);
    });

    testWidgets('con encabezado tocable se anuncia como botón expandible', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(wrap(onTapHeader: () {}));
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.bySemanticsLabel('Hábitos del día, 4 de 6')),
        isSemantics(isButton: true, hasExpandedState: true, isExpanded: false),
      );

      handle.dispose();
    });

    testWidgets('la card se ve con "reducir animaciones" activado', (
      tester,
    ) async {
      // `animate: false` de animate_do no salta la animación: deja el
      // controller en 0, o sea el hijo con opacidad 0 y desplazado. Sin el
      // wrapper condicional, la card quedaba invisible con la preferencia de
      // accesibilidad del sistema activada.
      await tester.pumpWidget(wrap(disableAnimations: true));
      await tester.pumpAndSettle();

      final opacidades = tester
          .widgetList<Opacity>(find.byType(Opacity))
          .map((o) => o.opacity);
      expect(opacidades, everyElement(greaterThan(0.0)));

      for (final t in tester.widgetList<Transform>(find.byType(Transform))) {
        expect(t.transform.getTranslation().y, 0.0);
      }
    });
  });
}
