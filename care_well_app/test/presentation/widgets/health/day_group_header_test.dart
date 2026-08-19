import 'package:care_well_app/config/theme/app_palette.dart';
import 'package:care_well_app/config/theme/app_theme.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Martes 18 de agosto de 2026. El "hoy" se inyecta: nada depende del reloj.
  final hoy = DateTime(2026, 8, 18);

  Widget wrap({
    required DateTime dia,
    int cantidad = 2,
    TextScaler textScaler = TextScaler.noScaling,
    ThemeMode themeMode = ThemeMode.light,
  }) {
    return MaterialApp(
      themeMode: themeMode,
      theme: AppTheme().light,
      darkTheme: AppTheme().dark,
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: textScaler),
          child: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: DayGroupHeader(dia: dia, cantidad: cantidad, hoy: hoy),
            ),
          ),
        ),
      ),
    );
  }

  /// Fondo del chip del día.
  Color? fondoDelChip(WidgetTester tester) {
    final chip = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(DayGroupHeader),
            matching: find.byType(Container),
          )
          .first,
    );
    return (chip.decoration! as BoxDecoration).color;
  }

  group('DayGroupHeader', () {
    testWidgets('el día de hoy se rotula "Hoy"', (tester) async {
      await tester.pumpWidget(wrap(dia: hoy));

      expect(find.text('Hoy'), findsOneWidget);
      expect(find.text('18'), findsOneWidget);
      expect(find.text('MAR'), findsOneWidget);
    });

    testWidgets('el día anterior se rotula "Ayer"', (tester) async {
      await tester.pumpWidget(wrap(dia: DateTime(2026, 8, 17)));

      expect(find.text('Ayer'), findsOneWidget);
      expect(find.text('17'), findsOneWidget);
      expect(find.text('LUN'), findsOneWidget);
    });

    testWidgets('el resto usa el nombre del día, capitalizado', (tester) async {
      // 15/08/2026 es sábado.
      await tester.pumpWidget(wrap(dia: DateTime(2026, 8, 15)));

      expect(find.text('Sábado'), findsOneWidget);
      expect(find.text('SÁB'), findsOneWidget);
    });

    testWidgets('el contador respeta el singular', (tester) async {
      await tester.pumpWidget(wrap(dia: hoy, cantidad: 1));
      expect(find.text('1 registro'), findsOneWidget);

      await tester.pumpWidget(wrap(dia: hoy, cantidad: 4));
      await tester.pumpAndSettle();
      expect(find.text('4 registros'), findsOneWidget);
    });

    testWidgets('hoy se destaca con el color del chip, no sólo con él', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(dia: hoy));
      expect(fondoDelChip(tester), AppPalette.light.primary);
      // El rótulo dice "Hoy": la marca no queda librada al color.
      expect(find.text('Hoy'), findsOneWidget);

      await tester.pumpWidget(wrap(dia: DateTime(2026, 8, 15)));
      await tester.pumpAndSettle();
      expect(fondoDelChip(tester), AppPalette.light.surface);
    });

    for (final (nombre, themeMode) in [
      ('claro', ThemeMode.light),
      ('oscuro', ThemeMode.dark),
    ]) {
      testWidgets('sin overflow en tema $nombre con textScaler 1.6', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(360 * 3, 640 * 3);
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          wrap(
            dia: DateTime(2026, 8, 12),
            cantidad: 12,
            textScaler: const TextScaler.linear(1.6),
            themeMode: themeMode,
          ),
        );
        await tester.pumpAndSettle();

        // El chip acota la escala en lugar de fijar su tamaño: el número y la
        // abreviatura tienen que seguir estando.
        expect(tester.takeException(), isNull);
        expect(find.text('12'), findsOneWidget);
        expect(find.text('MIÉ'), findsOneWidget);
        expect(find.text('12 registros'), findsOneWidget);
      });
    }
  });
}
