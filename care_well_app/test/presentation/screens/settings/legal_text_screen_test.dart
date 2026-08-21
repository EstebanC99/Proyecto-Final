import 'package:care_well_app/config/constraints/privacy_content.dart';
import 'package:care_well_app/config/theme/app_theme.dart';
import 'package:care_well_app/presentation/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LegalTextScreen', () {
    Widget wrap(Widget child) =>
        MaterialApp(theme: AppTheme().light, home: child);

    testWidgets('muestra título y contenido', (tester) async {
      await tester.pumpWidget(
        wrap(
          const LegalTextScreen(
            titulo: 'Política de privacidad',
            contenido: 'Texto legal de prueba.',
          ),
        ),
      );

      expect(find.text('Política de privacidad'), findsOneWidget);
      expect(find.text('Texto legal de prueba.'), findsOneWidget);
    });

    testWidgets('muestra la versión cuando se pasa', (tester) async {
      await tester.pumpWidget(
        wrap(
          const LegalTextScreen(
            titulo: 'Términos y condiciones',
            contenido: 'Texto legal de prueba.',
            version: '1.0 — Junio 2025',
          ),
        ),
      );

      expect(find.text('Versión 1.0 — Junio 2025'), findsOneWidget);
    });

    testWidgets('sin versión no muestra el encabezado de versión', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const LegalTextScreen(
            titulo: 'Términos y condiciones',
            contenido: 'Texto legal de prueba.',
          ),
        ),
      );

      expect(find.textContaining('Versión'), findsNothing);
    });

    testWidgets('muestra la ayuda de scroll solo si se pasa', (tester) async {
      await tester.pumpWidget(
        wrap(
          const LegalTextScreen(
            titulo: 'Términos y condiciones',
            contenido: 'Texto legal de prueba.',
          ),
        ),
      );
      expect(find.text('Deslizá para leer más'), findsNothing);

      await tester.pumpWidget(
        wrap(
          const LegalTextScreen(
            titulo: 'Términos y condiciones',
            contenido: 'Texto legal de prueba.',
            hintScroll: 'Deslizá para leer más',
          ),
        ),
      );
      expect(find.text('Deslizá para leer más'), findsOneWidget);
    });

    testWidgets('el contenido es desplazable', (tester) async {
      await tester.pumpWidget(
        wrap(
          const LegalTextScreen(
            titulo: 'Política de privacidad',
            contenido: kPrivacyContent,
            version: kPrivacyVersion,
          ),
        ),
      );

      final scroll = find.byType(SingleChildScrollView);
      expect(scroll, findsOneWidget);

      await tester.drag(scroll, const Offset(0, -400));
      await tester.pump();
    });
  });
}
