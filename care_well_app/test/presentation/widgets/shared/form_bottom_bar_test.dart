import 'package:care_well_app/config/theme/app_palette.dart';
import 'package:care_well_app/config/theme/app_theme.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap({
    VoidCallback? onPressed,
    bool loading = false,
    String? hint,
    String label = 'Registrar',
    EdgeInsets viewInsets = EdgeInsets.zero,
  }) {
    return MaterialApp(
      theme: AppTheme().light,
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(viewInsets: viewInsets),
          child: Scaffold(
            body: const SizedBox.expand(),
            bottomNavigationBar: FormBottomBar(
              label: label,
              onPressed: onPressed,
              accent: AppPalette.light.habitsAccent,
              loading: loading,
              hint: hint,
            ),
          ),
        ),
      ),
    );
  }

  group('FormBottomBar', () {
    testWidgets('dispara la acción al tocar el botón', (tester) async {
      var toques = 0;
      await tester.pumpWidget(wrap(onPressed: () => toques++));

      await tester.tap(find.text('Registrar'));
      await tester.pumpAndSettle();

      expect(toques, 1);
    });

    testWidgets('con onPressed nulo el botón queda deshabilitado', (
      tester,
    ) async {
      await tester.pumpWidget(wrap());

      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
    });

    testWidgets('mientras carga muestra el spinner y bloquea el botón', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(onPressed: () {}, loading: true));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Registrar'), findsNothing);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
    });

    testWidgets('el hint sólo se dibuja cuando no es nulo', (tester) async {
      await tester.pumpWidget(wrap(onPressed: () {}));
      expect(find.text('Falta la descripción'), findsNothing);

      await tester.pumpWidget(wrap(hint: 'Falta la descripción'));
      await tester.pumpAndSettle();

      expect(find.text('Falta la descripción'), findsOneWidget);
    });

    testWidgets('con el teclado abierto la barra queda por encima', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360 * 3, 640 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        wrap(onPressed: () {}, viewInsets: const EdgeInsets.only(bottom: 300)),
      );
      await tester.pumpAndSettle();

      // El Scaffold apoya el bottomNavigationBar contra el borde inferior de
      // la pantalla: sin el padding propio quedaría detrás del teclado.
      final cta = tester.getRect(find.byType(FilledButton));
      expect(cta.bottom, lessThanOrEqualTo(640 - 300));
    });
  });
}
