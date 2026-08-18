import 'package:care_well_app/config/theme/app_palette.dart';
import 'package:care_well_app/config/theme/app_theme.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    theme: AppTheme().light,
    home: Scaffold(body: child),
  );

  group('SectionLabel', () {
    testWidgets('muestra el texto en mayúsculas', (tester) async {
      await tester.pumpWidget(wrap(const SectionLabel(text: 'Seguimiento')));

      expect(find.text('SEGUIMIENTO'), findsOneWidget);
    });

    testWidgets('concatena el contador cuando se lo pasa', (tester) async {
      await tester.pumpWidget(
        wrap(const SectionLabel(text: 'Pendientes', count: 3)),
      );

      expect(find.text('PENDIENTES · 3'), findsOneWidget);
    });

    testWidgets('sin required no dibuja el asterisco', (tester) async {
      await tester.pumpWidget(wrap(const SectionLabel(text: 'Descripción')));

      final texto = tester.widget<Text>(find.byType(Text));
      expect(texto.data, 'DESCRIPCIÓN');
      expect(texto.textSpan, isNull);
    });

    testWidgets('con required agrega " *" en el color de error', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(const SectionLabel(text: 'Descripción', required: true)),
      );

      final texto = tester.widget<Text>(find.byType(Text));
      final span = texto.textSpan! as TextSpan;
      final hijos = span.children!.cast<TextSpan>();

      expect(hijos.first.text, 'DESCRIPCIÓN');
      expect(hijos.last.text, ' *');
      expect(hijos.last.style?.color, AppPalette.light.error);
    });

    testWidgets('con required la semántica aclara que es obligatorio', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(const SectionLabel(text: 'Descripción', required: true)),
      );

      expect(find.bySemanticsLabel('DESCRIPCIÓN, obligatorio'), findsOneWidget);
    });
  });
}
