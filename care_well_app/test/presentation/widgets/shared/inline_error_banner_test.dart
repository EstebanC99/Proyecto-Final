import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('InlineErrorBanner', () {
    testWidgets('renderiza el mensaje correctamente', (tester) async {
      await tester.pumpWidget(
        _wrap(const InlineErrorBanner(message: 'Error de prueba')),
      );

      expect(find.text('Error de prueba'), findsOneWidget);
    });

    testWidgets('muestra el ícono Icons.error_outline', (tester) async {
      await tester.pumpWidget(
        _wrap(const InlineErrorBanner(message: 'Algo salió mal')),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('sin onDismiss no ofrece cierre', (tester) async {
      await tester.pumpWidget(
        _wrap(const InlineErrorBanner(message: 'Algo salió mal')),
      );

      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('con onDismiss muestra la cruz y notifica el descarte', (
      tester,
    ) async {
      var descartado = false;
      await tester.pumpWidget(
        _wrap(
          InlineErrorBanner(
            message: 'Aviso descartable',
            tone: BannerTone.warning,
            onDismiss: () => descartado = true,
          ),
        ),
      );

      expect(find.byTooltip('Descartar aviso'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      expect(descartado, isTrue);
    });

    testWidgets('el área tocable del descarte respeta el mínimo accesible', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(InlineErrorBanner(message: 'Aviso', onDismiss: () {})),
      );

      // El ícono es de 18dp por jerarquía visual; el botón NO.
      final boton = tester.getSize(find.byType(IconButton));
      expect(boton.width, greaterThanOrEqualTo(48));
      expect(boton.height, greaterThanOrEqualTo(48));
    });
  });
}
