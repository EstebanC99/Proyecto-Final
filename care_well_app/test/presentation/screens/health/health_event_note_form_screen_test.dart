import 'package:care_well_app/config/theme/app_theme.dart';
import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/screens/health/health_event_note_form_screen.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// ─── Fixtures ─────────────────────────────────────────────────────────────────

const _eventoId = 42;

final _persona = Persona(
  id: 12,
  nombre: 'Alicia',
  apellido: 'Rodríguez',
  documento: '5234100',
  fechaNacimiento: DateTime(1943, 7, 22),
);

final _evento = EventoSalud(
  id: _eventoId,
  persona: const EntidadBasica(id: 12, descripcion: 'Alicia Rodríguez'),
  tipo: const TipoEventoSalud(id: 1, descripcion: 'Cita médica'),
  fechaHora: DateTime(2026, 8, 18, 10),
  descripcion: 'Control cardiológico anual',
);

// ─── Helpers ──────────────────────────────────────────────────────────────────

/// No-op con la firma de [agregarNotaEventoProvider].
Future<void> _agregarNoop({
  required int eventoSaludId,
  required String contenido,
}) async {}

ProviderContainer _container({
  Future<void> Function({
    required int eventoSaludId,
    required String contenido,
  })?
  agregar,
  bool conEvento = true,
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
      eventoSaludByIdProvider(
        _eventoId,
      ).overrideWith((ref) async => conEvento ? _evento : null),
      agregarNotaEventoProvider.overrideWithValue(agregar ?? _agregarNoop),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

/// Monta el formulario como ruta apilada, para que el `pop` tenga a dónde ir.
Future<void> _pushForm(
  WidgetTester tester,
  ProviderContainer container, {
  TextScaler textScaler = TextScaler.noScaling,
  ThemeMode themeMode = ThemeMode.light,
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
          data: MediaQuery.of(context).copyWith(textScaler: textScaler),
          child: child!,
        ),
        home: const Scaffold(body: Center(child: Text('pantalla anterior'))),
      ),
    ),
  );
  navKey.currentState!.push(
    MaterialPageRoute(
      builder: (_) => const HealthEventNoteFormScreen(eventoId: _eventoId),
    ),
  );
  await tester.pumpAndSettle();
}

FilledButton _cta(WidgetTester tester) =>
    tester.widget<FilledButton>(find.byType(FilledButton));

/// Dispara el gesto de "atrás" del sistema.
Future<void> _volverAtras(WidgetTester tester) async {
  final dynamic widgetsAppState = tester.state(find.byType(WidgetsApp));
  await widgetsAppState.didPopRoute();
  await tester.pumpAndSettle();
}

void main() {
  group('HealthEventNoteFormScreen', () {
    testWidgets('muestra el rótulo y el evento que se está anotando', (
      tester,
    ) async {
      await _pushForm(tester, _container());

      expect(find.byType(ContextAppBar), findsOneWidget);
      expect(find.text('NUEVA NOTA'), findsOneWidget);
      expect(find.text('Control cardiológico anual'), findsOneWidget);
      // Con la fecha y la hora: dos eventos del mismo tipo en el mismo día
      // serían indistinguibles sin ellas.
      expect(find.textContaining('18 ago'), findsOneWidget);
      expect(find.textContaining('10:00'), findsOneWidget);
    });

    testWidgets('sin el evento cargado la línea de contexto no se dibuja', (
      tester,
    ) async {
      // Es decorativa: si el evento no está en la semana cargada, la pantalla
      // funciona igual, sin spinner ni banner de error.
      await _pushForm(tester, _container(conEvento: false));

      expect(find.text('Control cardiológico anual'), findsNothing);
      expect(find.byType(FormTextField), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('el CTA se habilita recién cuando hay texto', (tester) async {
      await _pushForm(tester, _container());

      expect(_cta(tester).onPressed, isNull);
      expect(find.text('Escribí la nota para continuar'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'Tomó la medicación');
      await tester.pumpAndSettle();

      expect(_cta(tester).onPressed, isNotNull);
      expect(find.text('Escribí la nota para continuar'), findsNothing);
    });

    testWidgets('una nota de solo espacios no habilita el CTA', (tester) async {
      await _pushForm(tester, _container());

      await tester.enterText(find.byType(TextFormField), '    ');
      await tester.pumpAndSettle();

      expect(_cta(tester).onPressed, isNull);
    });

    testWidgets('guardar manda el evento y el contenido trimmeado', (
      tester,
    ) async {
      int? idEnviado;
      String? contenidoEnviado;
      final container = _container(
        agregar: ({required eventoSaludId, required contenido}) async {
          idEnviado = eventoSaludId;
          contenidoEnviado = contenido;
        },
      );
      await _pushForm(tester, container);

      await tester.enterText(
        find.byType(TextFormField),
        '  Se lo notó cansado  ',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Guardar nota'));
      await tester.pumpAndSettle();

      expect(idEnviado, _eventoId);
      expect(contenidoEnviado, 'Se lo notó cansado');
      expect(find.text('Nota guardada'), findsOneWidget);
      expect(find.text('pantalla anterior'), findsOneWidget);
    });

    testWidgets('si falla el guardado no cierra y avisa sin el prefijo', (
      tester,
    ) async {
      final container = _container(
        agregar: ({required eventoSaludId, required contenido}) async =>
            throw Exception('sin conexión'),
      );
      await _pushForm(tester, container);

      await tester.enterText(find.byType(TextFormField), 'Se lo notó cansado');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Guardar nota'));
      await tester.pumpAndSettle();

      expect(find.text('sin conexión'), findsOneWidget);
      expect(find.text('Exception: sin conexión'), findsNothing);
      // La pantalla sigue abierta y salió del estado de guardado.
      expect(find.byType(HealthEventNoteFormScreen), findsOneWidget);
      expect(find.text('Guardar nota'), findsOneWidget);
      expect(_cta(tester).onPressed, isNotNull);
    });

    testWidgets('sin texto, el gesto de atrás cierra sin preguntar', (
      tester,
    ) async {
      await _pushForm(tester, _container());

      await _volverAtras(tester);

      expect(find.text('Tenés cambios sin guardar'), findsNothing);
      expect(find.text('pantalla anterior'), findsOneWidget);
    });

    testWidgets('con texto, el gesto de atrás pide confirmación', (
      tester,
    ) async {
      await _pushForm(tester, _container());
      await tester.enterText(find.byType(TextFormField), 'Se lo notó cansado');
      await tester.pumpAndSettle();

      await _volverAtras(tester);

      expect(find.text('Tenés cambios sin guardar'), findsOneWidget);
      expect(find.text('pantalla anterior'), findsNothing);
    });

    testWidgets('cancelar la confirmación mantiene la nota en pantalla', (
      tester,
    ) async {
      await _pushForm(tester, _container());
      await tester.enterText(find.byType(TextFormField), 'Se lo notó cansado');
      await tester.pumpAndSettle();

      await _volverAtras(tester);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(find.byType(HealthEventNoteFormScreen), findsOneWidget);
      expect(find.text('Se lo notó cansado'), findsOneWidget);
    });

    testWidgets('confirmar la salida descarta la nota', (tester) async {
      await _pushForm(tester, _container());
      await tester.enterText(find.byType(TextFormField), 'Se lo notó cansado');
      await tester.pumpAndSettle();

      await _volverAtras(tester);
      await tester.tap(find.text('Salir'));
      await tester.pumpAndSettle();

      expect(find.text('pantalla anterior'), findsOneWidget);
    });
  });

  group('HealthEventNoteFormScreen · robustez de layout', () {
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
        expect(find.byType(FormTextField), findsOneWidget);
        expect(find.byType(FormBottomBar), findsOneWidget);
      });
    }
  });
}
