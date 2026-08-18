import 'package:care_well_app/config/theme/app_palette.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const palette = AppPalette.light;

  /// Genera [cantidad] opciones con ids 1..cantidad y rótulo "Tipo N".
  List<TypeTileOption> opciones(int cantidad) => [
    for (var i = 1; i <= cantidad; i++)
      TypeTileOption(
        id: i,
        label: 'Tipo $i',
        icon: Icons.circle,
        accent: palette.primary,
        container: palette.primaryContainer,
      ),
  ];

  Widget wrap({
    required List<TypeTileOption> options,
    int? selectedId,
    ValueChanged<int>? onChanged,
    bool enabled = true,
    int maxVisible = 6,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 360,
          child: TypeTileGrid(
            options: options,
            selectedId: selectedId,
            onChanged: onChanged ?? (_) {},
            enabled: enabled,
            maxVisible: maxVisible,
          ),
        ),
      ),
    );
  }

  group('TypeTileGrid', () {
    testWidgets('tocar un tile emite el id de la opción', (tester) async {
      int? elegido;
      await tester.pumpWidget(
        wrap(options: opciones(4), onChanged: (id) => elegido = id),
      );

      await tester.tap(find.text('Tipo 3'));
      await tester.pumpAndSettle();

      expect(elegido, 3);
    });

    testWidgets('con enabled: false no emite selección', (tester) async {
      int? elegido;
      await tester.pumpWidget(
        wrap(
          options: opciones(4),
          onChanged: (id) => elegido = id,
          enabled: false,
        ),
      );

      await tester.tap(find.text('Tipo 2'));
      await tester.pumpAndSettle();

      expect(elegido, isNull);
    });

    testWidgets('cada tile se anuncia como botón y marca la selección', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(wrap(options: opciones(4), selectedId: 2));
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.bySemanticsLabel('Tipo 2')),
        isSemantics(label: 'Tipo 2', isButton: true, isSelected: true),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Tipo 1')),
        isSemantics(label: 'Tipo 1', isButton: true, isSelected: false),
      );

      handle.dispose();
    });

    testWidgets('con opciones <= maxVisible no dibuja "Ver más"', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(options: opciones(6)));
      await tester.pumpAndSettle();

      expect(find.text('Ver más'), findsNothing);
      expect(find.text('Tipo 6'), findsOneWidget);
    });

    testWidgets('colapsada muestra maxVisible - 1 opciones más "Ver más"', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(options: opciones(9)));
      await tester.pumpAndSettle();

      expect(find.text('Tipo 5'), findsOneWidget);
      expect(find.text('Tipo 6'), findsNothing);
      expect(find.text('Ver más'), findsOneWidget);
    });

    testWidgets('"Ver más" despliega el resto y "Ver menos" lo colapsa', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(options: opciones(9)));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ver más'));
      await tester.pumpAndSettle();

      expect(find.text('Tipo 9'), findsOneWidget);
      expect(find.text('Ver menos'), findsOneWidget);

      await tester.tap(find.text('Ver menos'));
      await tester.pumpAndSettle();

      expect(find.text('Tipo 9'), findsNothing);
      expect(find.text('Ver más'), findsOneWidget);
    });

    testWidgets('arranca expandida si la selección está oculta', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(options: opciones(9), selectedId: 8));
      await tester.pumpAndSettle();

      expect(find.text('Tipo 8'), findsOneWidget);
      expect(find.text('Ver menos'), findsOneWidget);
    });

    testWidgets('arranca colapsada si la selección está visible', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(options: opciones(9), selectedId: 2));
      await tester.pumpAndSettle();

      expect(find.text('Tipo 6'), findsNothing);
      expect(find.text('Ver más'), findsOneWidget);
    });

    testWidgets('se expande si la selección oculta llega después del build', (
      tester,
    ) async {
      // Caso edición: el catálogo y el tipo guardado se resuelven async.
      await tester.pumpWidget(wrap(options: opciones(9)));
      await tester.pumpAndSettle();
      expect(find.text('Tipo 8'), findsNothing);

      await tester.pumpWidget(wrap(options: opciones(9), selectedId: 8));
      await tester.pumpAndSettle();

      expect(find.text('Tipo 8'), findsOneWidget);
    });

    testWidgets('respeta el orden recibido', (tester) async {
      final desordenadas = opciones(4).reversed.toList();
      await tester.pumpWidget(wrap(options: desordenadas));
      await tester.pumpAndSettle();

      final primero = tester.getTopLeft(find.text('Tipo 4'));
      final ultimo = tester.getTopLeft(find.text('Tipo 1'));
      expect(primero.dy, lessThanOrEqualTo(ultimo.dy));
    });
  });
}
