import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

/// Drena los timers de la animación de entrada (animate_do).
Future<void> _drainAnimations(WidgetTester tester) async {
  await tester.pump(Duration.zero);
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  group('SummaryHeroCard', () {
    group('estado con contenido', () {
      testWidgets('muestra título, texto y CTA', (tester) async {
        await tester.pumpWidget(
          _wrap(
            const SummaryHeroCard(
              state: SummaryHeroContent(texto: 'Buena mañana: todo en orden.'),
            ),
          ),
        );
        await _drainAnimations(tester);

        expect(find.text('Resumen del día'), findsOneWidget);
        expect(find.text('Buena mañana: todo en orden.'), findsOneWidget);
        expect(find.text('Ver resumen completo'), findsOneWidget);
        expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
      });

      testWidgets('muestra la hora de generación cuando se provee', (
        tester,
      ) async {
        await tester.pumpWidget(
          _wrap(
            SummaryHeroCard(
              state: SummaryHeroContent(
                texto: 'Resumen.',
                generadoEn: DateTime(2026, 8, 8, 9, 5),
              ),
            ),
          ),
        );
        await _drainAnimations(tester);

        expect(find.text('09:05'), findsOneWidget);
      });

      testWidgets('no muestra hora cuando generadoEn es null', (tester) async {
        await tester.pumpWidget(
          _wrap(const SummaryHeroCard(state: SummaryHeroContent(texto: 'X'))),
        );
        await _drainAnimations(tester);

        expect(find.textContaining(':'), findsNothing);
      });

      testWidgets('renderiza las pills provistas', (tester) async {
        await tester.pumpWidget(
          _wrap(
            const SummaryHeroCard(
              state: SummaryHeroContent(
                texto: 'Resumen.',
                pills: ['4 de 6 hábitos', '2 eventos'],
              ),
            ),
          ),
        );
        await _drainAnimations(tester);

        expect(find.text('4 de 6 hábitos'), findsOneWidget);
        expect(find.text('2 eventos'), findsOneWidget);
      });

      testWidgets('dispara onTapVerCompleto al tocar la card', (tester) async {
        var tapped = false;
        await tester.pumpWidget(
          _wrap(
            SummaryHeroCard(
              state: const SummaryHeroContent(texto: 'Resumen.'),
              onTapVerCompleto: () => tapped = true,
            ),
          ),
        );
        await _drainAnimations(tester);

        await tester.tap(find.text('Ver resumen completo'));
        await tester.pump();
        expect(tapped, isTrue);
      });
    });

    group('estados vacíos', () {
      testWidgets('noGenerado muestra su copy y el CTA de generación', (
        tester,
      ) async {
        await tester.pumpWidget(
          _wrap(
            const SummaryHeroCard(
              state: SummaryHeroEmpty(
                reason: SummaryHeroEmptyReason.noGenerado,
              ),
            ),
          ),
        );
        await _drainAnimations(tester);

        expect(
          find.text('Todavía no generamos tu resumen de hoy.'),
          findsOneWidget,
        );
        expect(find.text('Generar resumen'), findsOneWidget);
      });

      testWidgets('sinDatos muestra un copy distinto al de noGenerado', (
        tester,
      ) async {
        await tester.pumpWidget(
          _wrap(
            const SummaryHeroCard(
              state: SummaryHeroEmpty(reason: SummaryHeroEmptyReason.sinDatos),
            ),
          ),
        );
        await _drainAnimations(tester);

        expect(
          find.textContaining('Nada para resumir todavía'),
          findsOneWidget,
        );
        expect(find.text('Generar resumen'), findsNothing);
      });

      testWidgets('el reason por defecto es noGenerado', (tester) async {
        await tester.pumpWidget(
          _wrap(const SummaryHeroCard(state: SummaryHeroEmpty())),
        );
        await _drainAnimations(tester);

        expect(
          find.text('Todavía no generamos tu resumen de hoy.'),
          findsOneWidget,
        );
      });
    });
  });
}
