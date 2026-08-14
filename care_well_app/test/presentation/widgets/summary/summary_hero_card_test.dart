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
      testWidgets('noGenerado invita a elegir una persona a cargo', (
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
          find.text('Elegí una persona a cargo para ver su resumen del día.'),
          findsOneWidget,
        );
        expect(find.text('Ver resumen'), findsOneWidget);
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
        expect(find.textContaining('Elegí una persona'), findsNothing);
      });

      testWidgets('el reason por defecto es noGenerado', (tester) async {
        await tester.pumpWidget(
          _wrap(const SummaryHeroCard(state: SummaryHeroEmpty())),
        );
        await _drainAnimations(tester);

        expect(
          find.text('Elegí una persona a cargo para ver su resumen del día.'),
          findsOneWidget,
        );
      });
    });

    group('estado de carga', () {
      testWidgets('muestra el copy, el indicador y oculta la flecha', (
        tester,
      ) async {
        await tester.pumpWidget(
          _wrap(const SummaryHeroCard(state: SummaryHeroLoading())),
        );
        await tester.pump(Duration.zero);
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('Generando el resumen del día…'), findsOneWidget);
        expect(find.text('Generando…'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.byIcon(Icons.arrow_forward_rounded), findsNothing);
        // Sigue siendo la card del resumen, no un esqueleto.
        expect(find.text('Resumen del día'), findsOneWidget);
      });

      testWidgets('no navega mientras se genera', (tester) async {
        var tapped = false;
        await tester.pumpWidget(
          _wrap(
            SummaryHeroCard(
              state: const SummaryHeroLoading(),
              onTapVerCompleto: () => tapped = true,
            ),
          ),
        );
        await tester.pump(Duration.zero);
        await tester.pump(const Duration(milliseconds: 500));

        await tester.tap(find.text('Generando…'));
        await tester.pump();

        expect(tapped, isFalse);
      });
    });

    group('estado de error', () {
      testWidgets('muestra el copy y el CTA de reintento', (tester) async {
        await tester.pumpWidget(
          _wrap(const SummaryHeroCard(state: SummaryHeroError())),
        );
        await _drainAnimations(tester);

        expect(
          find.text('No pudimos generar el resumen ahora.'),
          findsOneWidget,
        );
        expect(find.text('Reintentar'), findsOneWidget);
      });

      testWidgets('el tap dispara onRetry y no onTapVerCompleto', (
        tester,
      ) async {
        var reintentos = 0;
        var navegaciones = 0;
        await tester.pumpWidget(
          _wrap(
            SummaryHeroCard(
              state: const SummaryHeroError(),
              onTapVerCompleto: () => navegaciones++,
              onRetry: () => reintentos++,
            ),
          ),
        );
        await _drainAnimations(tester);

        await tester.tap(find.text('Reintentar'));
        await tester.pump();

        expect(reintentos, 1);
        expect(navegaciones, 0);
      });
    });
  });
}
