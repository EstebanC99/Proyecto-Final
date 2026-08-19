import 'package:care_well_app/config/theme/app_palette.dart';
import 'package:care_well_app/config/theme/app_theme.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late TextEditingController controller;

  setUp(() => controller = TextEditingController());
  tearDown(() => controller.dispose());

  Widget wrap({
    bool enabled = true,
    int maxLength = 500,
    bool required = true,
    ValueChanged<String>? onChanged,
  }) {
    return MaterialApp(
      theme: AppTheme().light,
      home: Scaffold(
        body: FormTextField(
          controller: controller,
          label: 'Descripción',
          hintText: 'Describí el hábito registrado...',
          accent: AppPalette.light.habitsAccent,
          enabled: enabled,
          maxLength: maxLength,
          required: required,
          onChanged: onChanged,
        ),
      ),
    );
  }

  group('FormTextField', () {
    testWidgets('muestra rótulo, hint y contador en cero', (tester) async {
      await tester.pumpWidget(wrap());

      expect(find.text('DESCRIPCIÓN'), findsNothing);
      expect(find.bySemanticsLabel('DESCRIPCIÓN, obligatorio'), findsOneWidget);
      expect(find.text('Describí el hábito registrado...'), findsOneWidget);
      expect(find.text('0 / 500'), findsOneWidget);
    });

    testWidgets('sin required el rótulo va sin asterisco', (tester) async {
      await tester.pumpWidget(wrap(required: false));

      expect(find.text('DESCRIPCIÓN'), findsOneWidget);
    });

    testWidgets('el contador se actualiza solo, sin setState del padre', (
      tester,
    ) async {
      await tester.pumpWidget(wrap());

      await tester.enterText(find.byType(TextFormField), 'Hola');
      await tester.pump();

      expect(find.text('4 / 500'), findsOneWidget);
    });

    testWidgets('el contador también sigue cambios programáticos', (
      tester,
    ) async {
      await tester.pumpWidget(wrap());

      // Es el caso de la precarga en modo edición: el texto entra por el
      // controller, no por el teclado.
      controller.text = 'Doce chars.';
      await tester.pump();

      expect(find.text('11 / 500'), findsOneWidget);
    });

    testWidgets('propaga onChanged al padre', (tester) async {
      String? recibido;
      await tester.pumpWidget(wrap(onChanged: (v) => recibido = v));

      await tester.enterText(find.byType(TextFormField), 'Caminata');
      await tester.pump();

      expect(recibido, 'Caminata');
    });

    testWidgets('el contador nativo queda apagado', (tester) async {
      await tester.pumpWidget(wrap());

      await tester.enterText(find.byType(TextFormField), 'Hola');
      await tester.pump();

      // El nativo pinta "4/500" (sin espacios); el propio, "4 / 500".
      expect(find.text('4/500'), findsNothing);
      expect(find.text('4 / 500'), findsOneWidget);
    });

    testWidgets('respeta el maxLength recibido', (tester) async {
      await tester.pumpWidget(wrap(maxLength: 10));

      await tester.enterText(find.byType(TextFormField), 'a' * 20);
      await tester.pump();

      expect(controller.text.length, 10);
      expect(find.text('10 / 10'), findsOneWidget);
    });

    testWidgets('con enabled false el campo no acepta foco', (tester) async {
      await tester.pumpWidget(wrap(enabled: false));

      final campo = tester.widget<TextField>(find.byType(TextField));
      expect(campo.enabled, isFalse);
    });

    testWidgets('en una sola línea mantiene rótulo y contador', (tester) async {
      // El título de un evento de agenda: mismo widget, una sola línea.
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme().light,
          home: Scaffold(
            body: FormTextField(
              controller: controller,
              label: 'Título',
              hintText: 'Ej.: Control cardiológico',
              accent: AppPalette.light.primary,
              minLines: 1,
              maxLines: 1,
              maxLength: 120,
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('TÍTULO, obligatorio'), findsOneWidget);
      expect(find.text('0 / 120'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'Control anual');
      await tester.pump();

      expect(find.text('13 / 120'), findsOneWidget);
      expect(tester.widget<TextField>(find.byType(TextField)).maxLines, 1);
    });

    testWidgets('el contador cuenta grafemas, no unidades UTF-16', (
      tester,
    ) async {
      await tester.pumpWidget(wrap());

      // Un emoji es un solo carácter para `maxLength`, pero dos para `.length`.
      await tester.enterText(find.byType(TextFormField), 'ok 👍');
      await tester.pump();

      expect(find.text('4 / 500'), findsOneWidget);
    });
  });
}
