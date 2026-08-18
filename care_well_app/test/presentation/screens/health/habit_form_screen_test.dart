import 'package:care_well_app/config/theme/app_theme.dart';
import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/screens/health/habit_form_screen.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// ─── Fixtures ─────────────────────────────────────────────────────────────────

final _persona = Persona(
  id: 12,
  nombre: 'Alicia',
  apellido: 'Rodríguez',
  documento: '5234100',
  fechaNacimiento: DateTime(1943, 7, 22),
);

/// Catálogo completo, deliberadamente desordenado: la pantalla tiene que
/// ordenarlo por id para que "Otro" quede último.
final _tipos = [
  TipoHabitoVida(id: TiposHabitoConst.otro, descripcion: 'Otro'),
  TipoHabitoVida(
    id: TiposHabitoConst.actividadFisica,
    descripcion: 'Actividad física',
  ),
  TipoHabitoVida(id: TiposHabitoConst.hidratacion, descripcion: 'Hidratación'),
  TipoHabitoVida(
    id: TiposHabitoConst.alimentacion,
    descripcion: 'Alimentación',
  ),
  TipoHabitoVida(id: TiposHabitoConst.sueno, descripcion: 'Sueño'),
];

final _habitoExistente = HabitoVida(
  id: 7,
  persona: const EntidadBasica(id: 12, descripcion: 'Alicia Rodríguez'),
  tipo: TipoHabitoVida(
    id: TiposHabitoConst.hidratacion,
    descripcion: 'Hidratación',
  ),
  descripcion: 'Tomó 1,5 litros de agua durante el día.',
);

// ─── Helpers ──────────────────────────────────────────────────────────────────

/// No-op con la firma de [crearHabitoProvider].
Future<void> _crearNoop({
  required int tipoId,
  required String descripcion,
}) async {}

/// No-op con la firma de [modificarHabitoProvider].
Future<void> _modificarNoop({
  required int habitoId,
  required int tipoId,
  required String descripcion,
}) async {}

ProviderContainer _container({
  List<TipoHabitoVida>? tipos,
  Future<void> Function({required int tipoId, required String descripcion})?
  crear,
  Future<void> Function({
    required int habitoId,
    required int tipoId,
    required String descripcion,
  })?
  modificar,
}) {
  final container = ProviderContainer(
    overrides: [
      // El ContextAppBar resuelve persona, opciones y avatar por su cuenta.
      personaVisualizacionSeleccionadaProvider.overrideWith(
        (ref) async => _persona,
      ),
      personasSeleccionablesProvider.overrideWith(
        (ref) async => [
          PersonaContextOption(
            persona: _persona,
            rol: PersonaContextRol.responsable,
          ),
        ],
      ),
      personaImagenProvider.overrideWith((ref, id) async => null),
      tiposHabitoVidaProvider.overrideWith((ref) async => tipos ?? _tipos),
      habitoByIdProvider(
        _habitoExistente.id,
      ).overrideWith((ref) async => _habitoExistente),
      crearHabitoProvider.overrideWithValue(crear ?? _crearNoop),
      modificarHabitoProvider.overrideWithValue(modificar ?? _modificarNoop),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

/// Monta el formulario como ruta apilada (para que el `pop` posterior al
/// guardado tenga a dónde volver).
Future<void> _pushForm(
  WidgetTester tester,
  ProviderContainer container, {
  int? habitId,
  TextScaler textScaler = TextScaler.noScaling,
  ThemeMode themeMode = ThemeMode.light,
  EdgeInsets viewInsets = EdgeInsets.zero,
}) async {
  final navKey = GlobalKey<NavigatorState>();
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        navigatorKey: navKey,
        themeMode: themeMode,
        theme: AppTheme().light,
        darkTheme: AppTheme().dark,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: textScaler, viewInsets: viewInsets),
          child: child!,
        ),
        home: const Scaffold(body: SizedBox.shrink()),
      ),
    ),
  );
  navKey.currentState!.push(
    MaterialPageRoute(builder: (_) => HabitFormScreen(habitId: habitId)),
  );
  await tester.pumpAndSettle();
}

/// Campo de descripción del formulario.
Finder get _descripcion => find.byType(TextFormField);

/// Botón principal de la barra inferior.
FilledButton _cta(WidgetTester tester) =>
    tester.widget<FilledButton>(find.byType(FilledButton));

void main() {
  group('HabitFormScreen · alta', () {
    testWidgets('muestra el rótulo de alta y a la persona de contexto', (
      tester,
    ) async {
      await _pushForm(tester, _container());

      expect(find.byType(ContextAppBar), findsOneWidget);
      expect(find.text('NUEVO HÁBITO'), findsOneWidget);
      expect(find.text('Alicia Rodríguez'), findsOneWidget);
    });

    testWidgets('el contexto no es seleccionable desde el formulario', (
      tester,
    ) async {
      await _pushForm(tester, _container());

      // Sin chevron: no se puede cambiar de persona a mitad de la carga.
      expect(find.byIcon(Icons.expand_more), findsNothing);
    });

    testWidgets('dibuja un tile por tipo, ordenado por id y sin "Ver más"', (
      tester,
    ) async {
      await _pushForm(tester, _container());

      expect(find.byType(TypeTileGrid), findsOneWidget);
      for (final tipo in _tipos) {
        expect(find.text(tipo.descripcion), findsOneWidget);
      }
      // 5 tipos entran en el maxVisible por defecto (6).
      expect(find.text('Ver más'), findsNothing);

      // "Otro" (id 5) queda último pese a venir primero del catálogo.
      final primero = tester.getTopLeft(find.text('Actividad física'));
      final ultimo = tester.getTopLeft(find.text('Otro'));
      expect(ultimo.dy, greaterThan(primero.dy));
    });

    testWidgets('arranca con el primer tipo del catálogo seleccionado', (
      tester,
    ) async {
      int? tipoEnviado;
      final container = _container(
        crear: ({required tipoId, required descripcion}) async {
          tipoEnviado = tipoId;
        },
      );
      await _pushForm(tester, container);

      await tester.enterText(_descripcion, 'Caminata en el parque');
      await tester.pump();
      await tester.tap(find.text('Registrar'));
      await tester.pumpAndSettle();

      expect(tipoEnviado, TiposHabitoConst.actividadFisica);
    });

    testWidgets('tocar un tile cambia el tipo que se registra', (tester) async {
      int? tipoEnviado;
      final container = _container(
        crear: ({required tipoId, required descripcion}) async {
          tipoEnviado = tipoId;
        },
      );
      await _pushForm(tester, container);

      await tester.tap(find.text('Alimentación'));
      await tester.pump();
      await tester.enterText(_descripcion, 'Desayuno con avena');
      await tester.pump();
      await tester.tap(find.text('Registrar'));
      await tester.pumpAndSettle();

      expect(tipoEnviado, TiposHabitoConst.alimentacion);
    });

    testWidgets('el CTA se habilita recién cuando hay descripción', (
      tester,
    ) async {
      await _pushForm(tester, _container());

      expect(_cta(tester).onPressed, isNull);
      expect(
        find.text('Completá la descripción para continuar'),
        findsOneWidget,
      );

      await tester.enterText(_descripcion, 'Caminata en el parque');
      await tester.pumpAndSettle();

      expect(_cta(tester).onPressed, isNotNull);
      expect(find.text('Completá la descripción para continuar'), findsNothing);
    });

    testWidgets('una descripción de solo espacios no habilita el CTA', (
      tester,
    ) async {
      await _pushForm(tester, _container());

      await tester.enterText(_descripcion, '    ');
      await tester.pumpAndSettle();

      expect(_cta(tester).onPressed, isNull);
    });

    testWidgets('cambiar de categoría NO borra la descripción escrita', (
      tester,
    ) async {
      await _pushForm(tester, _container());

      await tester.enterText(_descripcion, 'Durmió toda la noche');
      await tester.pump();

      await tester.tap(find.text('Sueño'));
      await tester.pumpAndSettle();

      expect(find.text('Durmió toda la noche'), findsOneWidget);
      expect(_cta(tester).onPressed, isNotNull);
    });

    testWidgets('el contador refleja los caracteres escritos', (tester) async {
      await _pushForm(tester, _container());

      expect(find.text('0 / 500'), findsOneWidget);

      await tester.enterText(_descripcion, 'Hola');
      await tester.pumpAndSettle();

      expect(find.text('4 / 500'), findsOneWidget);
    });

    testWidgets('sin tipos en el catálogo el CTA queda deshabilitado', (
      tester,
    ) async {
      await _pushForm(tester, _container(tipos: []));

      expect(find.text('No hay tipos de hábito disponibles.'), findsOneWidget);
      expect(find.byType(TypeTileGrid), findsNothing);

      await tester.enterText(_descripcion, 'Algo');
      await tester.pumpAndSettle();

      expect(_cta(tester).onPressed, isNull);
    });
  });

  group('HabitFormScreen · edición', () {
    testWidgets('precarga el tipo y la descripción del hábito', (tester) async {
      await _pushForm(tester, _container(), habitId: _habitoExistente.id);

      expect(find.text('EDITAR HÁBITO'), findsOneWidget);
      expect(find.text(_habitoExistente.descripcion), findsOneWidget);
      expect(find.text('Guardar cambios'), findsOneWidget);
      expect(_cta(tester).onPressed, isNotNull);
    });

    testWidgets('cambiar de categoría preserva la descripción precargada', (
      tester,
    ) async {
      int? tipoEnviado;
      String? descripcionEnviada;
      final container = _container(
        modificar:
            ({required habitoId, required tipoId, required descripcion}) async {
              tipoEnviado = tipoId;
              descripcionEnviada = descripcion;
            },
      );
      await _pushForm(tester, container, habitId: _habitoExistente.id);

      await tester.tap(find.text('Alimentación'));
      await tester.pumpAndSettle();

      expect(find.text(_habitoExistente.descripcion), findsOneWidget);

      await tester.tap(find.text('Guardar cambios'));
      await tester.pumpAndSettle();

      expect(tipoEnviado, TiposHabitoConst.alimentacion);
      expect(descripcionEnviada, _habitoExistente.descripcion);
    });
  });

  group('HabitFormScreen · robustez de layout', () {
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

        await _pushForm(
          tester,
          _container(),
          textScaler: const TextScaler.linear(1.6),
          themeMode: themeMode,
        );

        expect(tester.takeException(), isNull);
        expect(find.byType(TypeTileGrid), findsOneWidget);
        expect(find.byType(FilledButton), findsOneWidget);
      });
    }

    testWidgets('con el teclado abierto la barra del CTA sigue visible', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360 * 3, 640 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await _pushForm(
        tester,
        _container(),
        // El teclado se come casi la mitad de la pantalla.
        viewInsets: const EdgeInsets.only(bottom: 300),
      );

      expect(tester.takeException(), isNull);

      // La barra queda apoyada sobre el teclado, no tapada por él.
      final cta = tester.getRect(find.byType(FilledButton));
      expect(cta.bottom, lessThanOrEqualTo(640 - 300));
      expect(cta.height, greaterThan(0));
    });
  });
}
