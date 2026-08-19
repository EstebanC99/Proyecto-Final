import 'package:care_well_app/config/theme/app_palette.dart';
import 'package:care_well_app/config/theme/app_theme.dart';
import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(EventoBase evento) => MaterialApp(
    theme: AppTheme().light,
    home: Scaffold(body: HealthTimelineTile(evento: evento)),
  );

  EventoBase evento({
    String categoria = 'Hábito',
    String descripcion = 'Caminata por el parque',
  }) => EventoBase(
    id: 1,
    descripcion: descripcion,
    categoriaEvento: categoria,
    fechaHora: DateTime(2026, 8, 18, 9, 5),
  );

  /// Color de fondo del cuadrado de categoría (el primer Container decorado).
  Color? fondoDeLaMarca(WidgetTester tester) {
    final contenedor = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(HealthTimelineTile),
            matching: find.byType(Container),
          )
          .first,
    );
    return (contenedor.decoration! as BoxDecoration).color;
  }

  group('HealthTimelineTile', () {
    testWidgets('muestra descripción, categoría y hora', (tester) async {
      await tester.pumpWidget(wrap(evento()));

      expect(find.text('Caminata por el parque'), findsOneWidget);
      expect(find.text('Hábito'), findsOneWidget);
      expect(find.text('09:05'), findsOneWidget);
    });

    testWidgets('la hora va a la derecha de la descripción', (tester) async {
      await tester.pumpWidget(wrap(evento()));

      final hora = tester.getCenter(find.text('09:05'));
      final descripcion = tester.getCenter(find.text('Caminata por el parque'));
      expect(hora.dx, greaterThan(descripcion.dx));
    });

    testWidgets('no dibuja emojis', (tester) async {
      await tester.pumpWidget(wrap(evento()));

      // Cualquier texto de la fila es contenido real, no un pictograma.
      final textos = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data ?? '');
      for (final texto in textos) {
        expect(
          RegExp(r'[\u{1F300}-\u{1FAFF}]', unicode: true).hasMatch(texto),
          isFalse,
          reason: 'la fila no debe traer emojis: "$texto"',
        );
      }
    });

    testWidgets('la marca toma el color contenedor de cada categoría', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(evento(categoria: 'Hábito')));
      expect(fondoDeLaMarca(tester), AppPalette.light.habitsContainer);

      await tester.pumpWidget(wrap(evento(categoria: 'Evento')));
      expect(fondoDeLaMarca(tester), AppPalette.light.healthContainer);

      await tester.pumpWidget(wrap(evento(categoria: 'Ánimo')));
      expect(fondoDeLaMarca(tester), AppPalette.light.moodContainer);
    });

    testWidgets('una categoría desconocida cae al neutro y no rompe', (
      tester,
    ) async {
      // El backend concatena la categoría como texto: si aparece una nueva, la
      // fila tiene que seguir dibujándose.
      await tester.pumpWidget(wrap(evento(categoria: 'Otra cosa')));

      expect(tester.takeException(), isNull);
      expect(fondoDeLaMarca(tester), AppPalette.light.surfaceVariant);
      expect(find.text('Otra cosa'), findsOneWidget);
    });

    testWidgets('conserva la lectura accesible de la fila', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(wrap(evento(categoria: 'Ánimo')));

      expect(
        find.bySemanticsLabel('Estado de ánimo: Caminata por el parque, 09:05'),
        findsOneWidget,
      );

      handle.dispose();
    });
  });
}
