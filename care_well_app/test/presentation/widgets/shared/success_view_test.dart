import 'package:care_well_app/presentation/widgets/shared/success_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(home: child);

void main() {
  group('SuccessView', () {
    testWidgets('muestra el título correctamente', (tester) async {
      await tester.pumpWidget(
        _wrap(
          SuccessView(
            title: '¡Éxito!',
            primaryButtonLabel: 'Continuar',
            onPrimaryTap: () {},
          ),
        ),
      );

      expect(find.text('¡Éxito!'), findsOneWidget);
    });

    testWidgets('muestra el nombre resaltado y el subtítulo', (tester) async {
      await tester.pumpWidget(
        _wrap(
          SuccessView(
            title: 'Persona registrada',
            highlightedName: 'Juan García',
            subtitle: ' fue agregado.',
            primaryButtonLabel: 'Ver lista',
            onPrimaryTap: () {},
          ),
        ),
      );

      expect(find.text('Persona registrada'), findsOneWidget);
      // RichText con TextSpans: buscamos por tipo RichText y verificamos el contenido.
      final richTexts = tester.widgetList<RichText>(find.byType(RichText));
      final textoCompleto = richTexts
          .map((rt) => rt.text.toPlainText())
          .join(' ');
      expect(textoCompleto, contains('Juan García'));
      expect(textoCompleto, contains('fue agregado.'));
    });

    testWidgets('muestra el botón primario con su etiqueta', (tester) async {
      await tester.pumpWidget(
        _wrap(
          SuccessView(
            title: 'Listo',
            primaryButtonLabel: 'Volver al inicio',
            onPrimaryTap: () {},
          ),
        ),
      );

      expect(find.text('Volver al inicio'), findsOneWidget);
    });

    testWidgets('dispara onPrimaryTap al presionar el botón primario', (
      tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        _wrap(
          SuccessView(
            title: 'Listo',
            primaryButtonLabel: 'Ir',
            onPrimaryTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.text('Ir'));
      expect(tapped, isTrue);
    });

    testWidgets('muestra el botón secundario cuando se provee', (tester) async {
      bool secondaryTapped = false;

      await tester.pumpWidget(
        _wrap(
          SuccessView(
            title: 'Listo',
            primaryButtonLabel: 'Ir',
            onPrimaryTap: () {},
            secondaryButtonLabel: 'Agregar otro',
            onSecondaryTap: () => secondaryTapped = true,
          ),
        ),
      );

      expect(find.text('Agregar otro'), findsOneWidget);

      await tester.tap(find.text('Agregar otro'));
      expect(secondaryTapped, isTrue);
    });

    testWidgets('no muestra botón secundario cuando no se provee', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          SuccessView(
            title: 'Listo',
            primaryButtonLabel: 'Ir',
            onPrimaryTap: () {},
          ),
        ),
      );

      // Solo debe haber un botón (el primario).
      expect(find.byType(GestureDetector), findsWidgets);
      // No debe haber texto de botón secundario.
      expect(find.text('Agregar otro'), findsNothing);
    });

    testWidgets('muestra el ícono check_circle_outline', (tester) async {
      await tester.pumpWidget(
        _wrap(
          SuccessView(
            title: 'Listo',
            primaryButtonLabel: 'Ir',
            onPrimaryTap: () {},
          ),
        ),
      );

      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });
  });
}
