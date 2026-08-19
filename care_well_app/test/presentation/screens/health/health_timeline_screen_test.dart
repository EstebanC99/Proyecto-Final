import 'package:care_well_app/config/theme/app_theme.dart';
import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/screens/screens.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

final _personaAlicia = Persona(
  id: 2,
  nombre: 'Alicia',
  apellido: 'Rodríguez',
  documento: '5234100',
  fechaNacimiento: DateTime(1943, 7, 22),
);

final _hoy = DateTime.now();

final _eventos = <EventoBase>[
  EventoBase(
    id: 1,
    descripcion: 'Caminata matutina',
    categoriaEvento: 'Hábito',
    fechaHora: DateTime(_hoy.year, _hoy.month, _hoy.day, 8),
  ),
  EventoBase(
    id: 2,
    descripcion: 'Control cardiológico',
    categoriaEvento: 'Evento',
    fechaHora: DateTime(_hoy.year, _hoy.month, _hoy.day, 11),
  ),
  EventoBase(
    id: 3,
    descripcion: 'Ánimo tranquilo',
    categoriaEvento: 'Ánimo',
    fechaHora: DateTime(_hoy.year, _hoy.month, _hoy.day, 20),
  ),
];
Widget _wrap({
  List<EventoBase>? eventos,
  Persona? persona,
  TextScaler textScaler = TextScaler.noScaling,
  ThemeMode themeMode = ThemeMode.light,
}) {
  return ProviderScope(
    overrides: [
      lineaTiempoDelMesProvider.overrideWith(
        (ref) async => eventos ?? _eventos,
      ),
      personaVisualizacionSeleccionadaProvider.overrideWith(
        (ref) async => persona ?? _personaAlicia,
      ),
      // El banner del ContextSelector renderiza un PersonaAvatar; se evita que
      // golpee el repositorio real cayendo al fallback de iniciales.
      personaImagenProvider.overrideWith((ref, id) async => null),
    ],
    child: MaterialApp(
      themeMode: themeMode,
      theme: AppTheme().light,
      darkTheme: AppTheme().dark,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: textScaler),
        child: child!,
      ),
      home: const HealthTimelineScreen(),
    ),
  );
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  group('HealthTimelineScreen', () {
    testWidgets('smoke: renderiza sin errores', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(HealthTimelineScreen), findsOneWidget);
    });

    testWidgets('muestra la línea de tiempo con las 3 categorías', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(HealthTimelineView), findsOneWidget);
      expect(find.byType(HealthTimelineTile), findsNWidgets(3));
    });

    testWidgets('no expone FAB (solo lectura)', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('muestra estado vacío cuando no hay registros', (tester) async {
      await tester.pumpWidget(_wrap(eventos: []));
      await tester.pump();
      expect(find.text('Sin registros en este mes.'), findsOneWidget);
    });

    // ─── Rediseño visual (fase 6) ───────────────────────────────────────────

    testWidgets('el día más reciente queda arriba', (tester) async {
      final ayer = _hoy.subtract(const Duration(days: 1));
      await tester.pumpWidget(
        _wrap(
          eventos: [
            EventoBase(
              id: 10,
              descripcion: 'Registro de ayer',
              categoriaEvento: 'Hábito',
              fechaHora: DateTime(ayer.year, ayer.month, ayer.day, 9),
            ),
            EventoBase(
              id: 11,
              descripcion: 'Registro de hoy',
              categoriaEvento: 'Hábito',
              fechaHora: DateTime(_hoy.year, _hoy.month, _hoy.day, 9),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final hoy = tester.getTopLeft(find.text('Registro de hoy'));
      final ayerPos = tester.getTopLeft(find.text('Registro de ayer'));
      expect(hoy.dy, lessThan(ayerPos.dy));
      expect(find.text('Hoy'), findsOneWidget);
      expect(find.text('Ayer'), findsOneWidget);
    });

    testWidgets('dentro del día lo más temprano va primero', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      final manana = tester.getTopLeft(find.text('Caminata matutina'));
      final mediodia = tester.getTopLeft(find.text('Control cardiológico'));
      final noche = tester.getTopLeft(find.text('Ánimo tranquilo'));
      expect(manana.dy, lessThan(mediodia.dy));
      expect(mediodia.dy, lessThan(noche.dy));
    });

    testWidgets('la lista arranca arriba, sin saltar al fondo', (tester) async {
      // Los tres registros del día van en una sola tarjeta y ya no hay
      // auto-scroll: el usuario ve el encabezado del día más reciente.
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      final scrollable = tester.widget<Scrollable>(
        find.byType(Scrollable).first,
      );
      expect(scrollable.controller?.offset ?? 0, 0);
      expect(find.byType(DayGroupHeader), findsOneWidget);
    });

    testWidgets('agrupa los registros del día en una sola tarjeta', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.byType(HealthTimelineTile), findsNWidgets(3));
      expect(find.byType(DayGroupHeader), findsOneWidget);
      expect(find.text('3 registros'), findsOneWidget);
    });
  });

  group('HealthTimelineScreen · robustez de layout', () {
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
          _wrap(textScaler: const TextScaler.linear(1.6), themeMode: themeMode),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(DayGroupHeader), findsOneWidget);
        expect(find.byType(HealthTimelineTile), findsNWidgets(3));
      });
    }
  });

  /// Toca un chip del filtro. El finder se acota: el rótulo de la categoría
  /// también aparece en cada fila.
  Future<void> tocarChip(WidgetTester tester, String texto) async {
    await tester.tap(
      find.descendant(
        of: find.byType(TimelineCategoryFilter),
        matching: find.text(texto),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('HealthTimelineScreen · filtro por categoría', () {
    testWidgets('arranca en "Todo" y muestra las tres categorías', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.byType(TimelineCategoryFilter), findsOneWidget);
      expect(find.byType(HealthTimelineTile), findsNWidgets(3));
    });

    testWidgets('filtrar deja sólo los registros de esa categoría', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      await tocarChip(tester, 'Hábito');

      expect(find.text('Caminata matutina'), findsOneWidget);
      expect(find.text('Control cardiológico'), findsNothing);
      expect(find.text('Ánimo tranquilo'), findsNothing);
      expect(find.text('1 registro'), findsOneWidget);
    });

    testWidgets('"Todo" restaura la lista completa', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      await tocarChip(tester, 'Hábito');
      expect(find.byType(HealthTimelineTile), findsOneWidget);

      await tocarChip(tester, 'Todo');

      expect(find.byType(HealthTimelineTile), findsNWidgets(3));
    });

    testWidgets('un filtro sin resultados muestra su propio vacío', (
      tester,
    ) async {
      // Sólo hay un hábito: al pedir eventos de salud no queda nada, y el
      // mensaje tiene que decir que es por el filtro, no que el mes esté vacío.
      await tester.pumpWidget(
        _wrap(
          eventos: [
            EventoBase(
              id: 1,
              descripcion: 'Caminata matutina',
              categoriaEvento: 'Hábito',
              fechaHora: DateTime(_hoy.year, _hoy.month, _hoy.day, 8),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await tocarChip(tester, 'Evento de salud');

      expect(
        find.text('Sin registros de evento de salud en este mes.'),
        findsOneWidget,
      );
      expect(find.text('Sin registros en este mes.'), findsNothing);
      // El filtro sigue a la vista para poder volver atrás.
      expect(find.byType(TimelineCategoryFilter), findsOneWidget);
    });

    testWidgets('el mes vacío conserva su mensaje propio', (tester) async {
      await tester.pumpWidget(_wrap(eventos: []));
      await tester.pumpAndSettle();

      expect(find.text('Sin registros en este mes.'), findsOneWidget);
    });
  });
}
