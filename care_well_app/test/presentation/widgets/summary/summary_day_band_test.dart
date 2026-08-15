import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('SummaryDayBand', () {
    testWidgets('muestra la fecha larga capitalizada y el ánimo', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          SummaryDayBand(
            fecha: DateTime(2026, 8, 8),
            estadoAnimo: 'Alegre y con energía',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sábado 8 de agosto'), findsOneWidget);
      expect(find.text('Alegre y con energía'), findsOneWidget);
    });

    testWidgets('sin estado de ánimo no pinta el chip', (tester) async {
      await tester.pumpWidget(
        _wrap(SummaryDayBand(fecha: DateTime(2026, 8, 8))),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.mood), findsNothing);
    });

    testWidgets('sin generadoEn no pinta el chip de generación', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(SummaryDayBand(fecha: DateTime(2026, 8, 8))),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Generado'), findsNothing);
    });

    testWidgets('con generadoEn reciente el chip dice "recién"', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          SummaryDayBand(
            fecha: DateTime(2026, 8, 8),
            generadoEn: DateTime.now(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Generado recién'), findsOneWidget);
    });

    testWidgets('la fecha y el chip de generación comparten renglón', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          SummaryDayBand(
            fecha: DateTime(2026, 8, 8),
            estadoAnimo: 'Alegre y con energía',
            generadoEn: DateTime.now(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final fecha = tester.getCenter(find.text('Sábado 8 de agosto'));
      final generacion = tester.getCenter(find.text('Generado recién'));
      expect(fecha.dy, moreOrLessEquals(generacion.dy, epsilon: 2));

      // El ánimo va debajo de las dos.
      final animo = tester.getTopLeft(find.text('Alegre y con energía'));
      expect(animo.dy, greaterThan(fecha.dy));
      expect(animo.dy, greaterThan(generacion.dy));
    });

    testWidgets('el chip de generación termina contra el borde de la franja', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          SummaryDayBand(
            fecha: DateTime(2026, 8, 8),
            estadoAnimo: 'Alegre y con energía',
            generadoEn: DateTime.now(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Container más cercano al ícono del reloj: el chip de generación.
      final chip = find
          .ancestor(
            of: find.byIcon(Icons.schedule),
            matching: find.byType(Container),
          )
          .first;

      // Mismo borde derecho que la franja, que es el de las cards de abajo.
      expect(
        tester.getBottomRight(chip).dx,
        moreOrLessEquals(
          tester.getBottomRight(find.byType(SummaryDayBand)).dx,
          epsilon: 0.5,
        ),
      );
    });

    testWidgets('el chip de ánimo ocupa el ancho de la franja', (tester) async {
      await tester.pumpWidget(
        _wrap(
          SummaryDayBand(
            fecha: DateTime(2026, 8, 8),
            estadoAnimo: 'Alegre y con energía',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Container más cercano al ícono del chip: el chip mismo.
      final chip = find
          .ancestor(
            of: find.byIcon(Icons.mood),
            matching: find.byType(Container),
          )
          .first;

      expect(
        tester.getSize(chip).width,
        moreOrLessEquals(
          tester.getSize(find.byType(SummaryDayBand)).width,
          epsilon: 0.5,
        ),
      );
    });

    testWidgets('un estado de ánimo largo se muestra completo, sin recortes', (
      tester,
    ) async {
      const animoLargo =
          'Estuvo alegre y conversadora durante casi toda la mañana, algo más '
          'cansada después del almuerzo y volvió a animarse por la tarde '
          'cuando llegaron las visitas.';

      await tester.pumpWidget(
        _wrap(
          SummaryDayBand(fecha: DateTime(2026, 8, 8), estadoAnimo: animoLargo),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(animoLargo), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Sin `maxLines`: el texto envuelve en todas las líneas que necesite.
      final texto = tester.widget<Text>(find.text(animoLargo));
      expect(texto.maxLines, isNull);
      expect(texto.overflow, isNull);
    });

    testWidgets(
      'una fecha de generación en el futuro también dice "recién" (relojes '
      'desfasados entre servidor y teléfono)',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            SummaryDayBand(
              fecha: DateTime(2026, 8, 8),
              generadoEn: DateTime.now().add(const Duration(hours: 3)),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Generado recién'), findsOneWidget);
      },
    );
  });
}
