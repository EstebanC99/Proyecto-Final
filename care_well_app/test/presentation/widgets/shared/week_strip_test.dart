import 'package:care_well_app/config/theme/app_palette.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Semana de referencia: lunes 10/08/2026 a domingo 16/08/2026.
final _lunes = DateTime(2026, 8, 10);
final _hoy = DateTime(2026, 8, 12); // miércoles

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

WeekStrip _strip({
  DateTime? lunesSemana,
  DateTime? diaSeleccionado,
  Map<DateTime, int> cantidadPorDia = const {},
  ValueChanged<DateTime>? onSelectDia,
  VoidCallback? onPreviousWeek,
  VoidCallback? onNextWeek,
  bool habilitarPrevia = true,
  bool habilitarSiguiente = true,
  Color? accentColor,
  DateTime? maxDiaSeleccionable,
}) => WeekStrip(
  lunesSemana: lunesSemana ?? _lunes,
  diaSeleccionado: diaSeleccionado ?? _hoy,
  cantidadPorDia: cantidadPorDia,
  onSelectDia: onSelectDia ?? (_) {},
  onPreviousWeek: habilitarPrevia ? (onPreviousWeek ?? () {}) : null,
  onNextWeek: habilitarSiguiente ? (onNextWeek ?? () {}) : null,
  accentColor: accentColor,
  maxDiaSeleccionable: maxDiaSeleccionable,
  hoy: _hoy,
);

/// Color del texto renderizado para [texto].
Color? _colorTexto(WidgetTester tester, String texto) =>
    tester.widget<Text>(find.text(texto)).style?.color;

void main() {
  group('WeekStrip', () {
    testWidgets('muestra los siete días de la semana', (tester) async {
      await tester.pumpWidget(_wrap(_strip()));

      for (final etiqueta in ['LU', 'MA', 'MI', 'JU', 'VI', 'SÁ', 'DO']) {
        expect(find.text(etiqueta), findsOneWidget);
      }
      for (var dia = 10; dia <= 16; dia++) {
        expect(find.text('$dia'), findsOneWidget);
      }
    });

    testWidgets('muestra el mes y el año de la semana', (tester) async {
      await tester.pumpWidget(_wrap(_strip()));

      expect(find.text('Agosto 2026'), findsOneWidget);
    });

    testWidgets('cuando la semana cruza dos meses muestra ambos', (
      tester,
    ) async {
      // Lunes 31/08/2026 → domingo 06/09/2026.
      await tester.pumpWidget(
        _wrap(
          _strip(
            lunesSemana: DateTime(2026, 8, 31),
            diaSeleccionado: DateTime(2026, 8, 31),
          ),
        ),
      );

      expect(find.text('Ago · Sep 2026'), findsOneWidget);
    });

    testWidgets('el día seleccionado se pinta con el color primario', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(_strip(diaSeleccionado: DateTime(2026, 8, 14))),
      );

      final rellenos = tester
          .widgetList<Container>(find.byType(Container))
          .map((c) => c.decoration)
          .whereType<BoxDecoration>()
          .where((d) => d.color == AppPalette.light.primary);

      expect(rellenos.length, 1);
    });

    testWidgets('al tocar un día se informa la fecha completa', (tester) async {
      DateTime? seleccionado;
      await tester.pumpWidget(
        _wrap(_strip(onSelectDia: (dia) => seleccionado = dia)),
      );

      await tester.tap(find.text('14'));
      await tester.pump();

      expect(seleccionado, DateTime(2026, 8, 14));
    });

    testWidgets('las flechas navegan entre semanas', (tester) async {
      var previas = 0;
      var siguientes = 0;
      await tester.pumpWidget(
        _wrap(
          _strip(
            onPreviousWeek: () => previas++,
            onNextWeek: () => siguientes++,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.chevron_left_rounded));
      await tester.tap(find.byIcon(Icons.chevron_right_rounded));
      await tester.pump();

      expect(previas, 1);
      expect(siguientes, 1);
    });

    group('swipe horizontal', () {
      testWidgets('deslizar hacia la derecha va a la semana anterior', (
        tester,
      ) async {
        var previas = 0;
        var siguientes = 0;
        await tester.pumpWidget(
          _wrap(
            _strip(
              onPreviousWeek: () => previas++,
              onNextWeek: () => siguientes++,
            ),
          ),
        );

        await tester.fling(find.byType(WeekStrip), const Offset(300, 0), 1000);
        await tester.pumpAndSettle();

        expect(previas, 1);
        expect(siguientes, 0);
      });

      testWidgets('deslizar hacia la izquierda va a la semana siguiente', (
        tester,
      ) async {
        var previas = 0;
        var siguientes = 0;
        await tester.pumpWidget(
          _wrap(
            _strip(
              onPreviousWeek: () => previas++,
              onNextWeek: () => siguientes++,
            ),
          ),
        );

        await tester.fling(find.byType(WeekStrip), const Offset(-300, 0), 1000);
        await tester.pumpAndSettle();

        expect(siguientes, 1);
        expect(previas, 0);
      });

      testWidgets('un arrastre lento no cambia de semana', (tester) async {
        var previas = 0;
        var siguientes = 0;
        await tester.pumpWidget(
          _wrap(
            _strip(
              onPreviousWeek: () => previas++,
              onNextWeek: () => siguientes++,
            ),
          ),
        );

        // drag() suelta el dedo sin velocidad: por debajo del umbral.
        await tester.drag(find.byType(WeekStrip), const Offset(120, 0));
        await tester.pumpAndSettle();

        expect(previas, 0);
        expect(siguientes, 0);
      });

      testWidgets('el swipe no dispara la selección de día', (tester) async {
        DateTime? seleccionado;
        await tester.pumpWidget(
          _wrap(_strip(onSelectDia: (dia) => seleccionado = dia)),
        );

        await tester.fling(find.text('14'), const Offset(-300, 0), 1000);
        await tester.pumpAndSettle();

        expect(seleccionado, isNull);
      });
    });

    testWidgets('dibuja un pip por evento, con tope de 3', (tester) async {
      await tester.pumpWidget(
        _wrap(
          _strip(
            cantidadPorDia: {
              DateTime(2026, 8, 11): 2,
              DateTime(2026, 8, 13): 7, // se recorta a 3
            },
          ),
        ),
      );

      // Los pips son los únicos contenedores circulares de 4x4.
      final pips = tester
          .widgetList<Container>(find.byType(Container))
          .where(
            (c) =>
                c.constraints?.maxWidth == 4 && c.constraints?.maxHeight == 4,
          );

      expect(pips.length, 5);
    });

    testWidgets('sin eventos no dibuja pips', (tester) async {
      await tester.pumpWidget(_wrap(_strip()));

      final pips = tester
          .widgetList<Container>(find.byType(Container))
          .where(
            (c) =>
                c.constraints?.maxWidth == 4 && c.constraints?.maxHeight == 4,
          );

      expect(pips, isEmpty);
    });

    group('navegación deshabilitada', () {
      testWidgets('la flecha sin callback se muestra atenuada', (tester) async {
        await tester.pumpWidget(_wrap(_strip(habilitarSiguiente: false)));

        final siguiente = tester.widget<Icon>(
          find.byIcon(Icons.chevron_right_rounded),
        );
        final anterior = tester.widget<Icon>(
          find.byIcon(Icons.chevron_left_rounded),
        );

        expect(siguiente.color, AppPalette.light.textDisabled);
        expect(anterior.color, AppPalette.light.primary);
      });

      testWidgets('tocar la flecha sin callback no rompe ni navega', (
        tester,
      ) async {
        var previas = 0;
        await tester.pumpWidget(
          _wrap(
            _strip(habilitarSiguiente: false, onPreviousWeek: () => previas++),
          ),
        );

        await tester.tap(find.byIcon(Icons.chevron_right_rounded));
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(previas, 0);
      });

      testWidgets('el swipe hacia la semana deshabilitada no hace nada', (
        tester,
      ) async {
        var previas = 0;
        await tester.pumpWidget(
          _wrap(
            _strip(habilitarSiguiente: false, onPreviousWeek: () => previas++),
          ),
        );

        // Hacia la izquierda = semana siguiente (deshabilitada).
        await tester.fling(find.byType(WeekStrip), const Offset(-300, 0), 1000);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // La dirección habilitada sigue funcionando.
        await tester.fling(find.byType(WeekStrip), const Offset(300, 0), 1000);
        await tester.pumpAndSettle();
        expect(previas, 1);
      });
    });

    group('color de acento', () {
      testWidgets('pinta el día seleccionado con el acento indicado', (
        tester,
      ) async {
        const acento = Color(0xFF123456);
        await tester.pumpWidget(
          _wrap(
            _strip(diaSeleccionado: DateTime(2026, 8, 14), accentColor: acento),
          ),
        );

        final rellenos = tester
            .widgetList<Container>(find.byType(Container))
            .map((c) => c.decoration)
            .whereType<BoxDecoration>()
            .where((d) => d.color == acento);

        expect(rellenos.length, 1);
      });

      testWidgets('resalta el día de hoy con el acento indicado', (
        tester,
      ) async {
        const acento = Color(0xFF123456);
        await tester.pumpWidget(
          _wrap(
            _strip(diaSeleccionado: DateTime(2026, 8, 10), accentColor: acento),
          ),
        );

        expect(_colorTexto(tester, '12'), acento);
      });
    });

    group('días no seleccionables', () {
      testWidgets('los días posteriores al máximo se muestran atenuados', (
        tester,
      ) async {
        await tester.pumpWidget(
          _wrap(_strip(maxDiaSeleccionable: DateTime(2026, 8, 13))),
        );

        expect(_colorTexto(tester, '14'), AppPalette.light.textDisabled);
        expect(_colorTexto(tester, '16'), AppPalette.light.textDisabled);
        // El día límite sigue habilitado.
        expect(_colorTexto(tester, '13'), isNot(AppPalette.light.textDisabled));
      });

      testWidgets('tocar un día posterior al máximo no lo selecciona', (
        tester,
      ) async {
        DateTime? seleccionado;
        await tester.pumpWidget(
          _wrap(
            _strip(
              maxDiaSeleccionable: DateTime(2026, 8, 13),
              onSelectDia: (dia) => seleccionado = dia,
            ),
          ),
        );

        await tester.tap(find.text('15'));
        await tester.pump();
        expect(seleccionado, isNull);

        await tester.tap(find.text('13'));
        await tester.pump();
        expect(seleccionado, DateTime(2026, 8, 13));
      });
    });
  });
}
