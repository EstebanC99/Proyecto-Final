import 'package:care_well_app/config/theme/app_theme.dart';
import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/screens/screens.dart';
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

final _animoDeHoy = PersonaEstadoAnimo(
  id: 5,
  persona: _persona,
  fecha: DateTime(2026, 8, 18, 10, 46),
  estado: const EstadoAnimo(
    id: EstadosAnimoConst.muyBien,
    descripcion: 'Muy bien',
  ),
);

typedef _RegistrarAnimo =
    Future<void> Function({required int estadoAnimoId, String? observaciones});

// ─── Helpers ──────────────────────────────────────────────────────────────────

Widget _wrap({
  _RegistrarAnimo? onRegistrar,
  PersonaEstadoAnimo? animoHoy,
  TextScaler textScaler = TextScaler.noScaling,
  ThemeMode themeMode = ThemeMode.light,
}) {
  return ProviderScope(
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
      animoHoyProvider.overrideWith((ref) async => animoHoy),
      registrarAnimoProvider.overrideWithValue(
        onRegistrar ?? (({required estadoAnimoId, observaciones}) async {}),
      ),
    ],
    child: MaterialApp(
      themeMode: themeMode,
      theme: AppTheme().light,
      darkTheme: AppTheme().dark,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: textScaler),
        child: child!,
      ),
      home: const MoodFormScreen(),
    ),
  );
}

FilledButton _cta(WidgetTester tester) =>
    tester.widget<FilledButton>(find.byType(FilledButton));

/// Toca "Registrar estado" y drena los timers del SnackBar de éxito.
Future<void> _registrar(WidgetTester tester) async {
  await tester.tap(find.text('Registrar estado'));
  await tester.pump();
  await tester.pump(const Duration(seconds: 5));
}

Finder _campoObservacion() => find.byType(TextFormField);

void main() {
  group('MoodFormScreen', () {
    testWidgets('arranca sin selección y con el botón bloqueado', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.text('¿Cómo se siente Alicia hoy?'), findsOneWidget);
      expect(_cta(tester).onPressed, isNull);
      expect(find.text('Elegí cómo se siente para continuar'), findsOneWidget);

      // Ningún nivel viene preseleccionado.
      final selector = tester.widget<MoodScaleSelector>(
        find.byType(MoodScaleSelector),
      );
      expect(selector.selectedLevel, isNull);
      for (final nivel in moodLevels) {
        expect(
          tester.getSemantics(find.bySemanticsLabel(nivel.label)),
          isSemantics(isButton: true, isSelected: false),
        );
      }

      handle.dispose();
    });

    testWidgets('elegir un nivel habilita el botón y registra ese nivel', (
      tester,
    ) async {
      int? registrado;
      await tester.pumpWidget(
        _wrap(
          onRegistrar: ({required estadoAnimoId, observaciones}) async {
            registrado = estadoAnimoId;
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Bien'));
      await tester.pumpAndSettle();

      expect(_cta(tester).onPressed, isNotNull);
      expect(find.text('Elegí cómo se siente para continuar'), findsNothing);

      await _registrar(tester);

      expect(registrado, EstadosAnimoConst.bien);
    });

    testWidgets('sin observación se manda null, no cadena vacía', (
      tester,
    ) async {
      var llamado = false;
      String? enviado = 'centinela';
      await tester.pumpWidget(
        _wrap(
          onRegistrar: ({required estadoAnimoId, observaciones}) async {
            llamado = true;
            enviado = observaciones;
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Regular'));
      await tester.pumpAndSettle();
      await _registrar(tester);

      expect(llamado, isTrue);
      expect(enviado, isNull);
    });

    testWidgets('la observación se manda trimmeada', (tester) async {
      String? enviado;
      await tester.pumpWidget(
        _wrap(
          onRegistrar: ({required estadoAnimoId, observaciones}) async {
            enviado = observaciones;
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Mal'));
      await tester.pumpAndSettle();
      await tester.enterText(_campoObservacion(), '   Le costó dormir   ');
      await tester.pumpAndSettle();
      await _registrar(tester);

      expect(enviado, 'Le costó dormir');
    });
  });

  group('MoodFormScreen · chips de sugerencia', () {
    testWidgets('el primer chip escribe su texto tal cual', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Durmió bien'));
      await tester.pumpAndSettle();

      expect(find.text('Durmió bien'), findsNWidgets(2)); // chip + campo
    });

    testWidgets('el segundo chip se concatena con ". "', (tester) async {
      String? enviado;
      await tester.pumpWidget(
        _wrap(
          onRegistrar: ({required estadoAnimoId, observaciones}) async {
            enviado = observaciones;
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Durmió bien'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Con energía'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Bien'));
      await tester.pumpAndSettle();
      await _registrar(tester);

      expect(enviado, 'Durmió bien. Con energía');
    });

    testWidgets('no duplica: el chip ya usado queda deshabilitado', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ansioso'));
      await tester.pumpAndSettle();

      // El chip se deshabilita en vez de responder con silencio. El finder se
      // acota al Wrap: el texto también está ahora dentro del campo.
      final chip = find.descendant(
        of: find.byType(Wrap),
        matching: find.widgetWithText(InkWell, 'Ansioso'),
      );
      expect(tester.widget<InkWell>(chip).onTap, isNull);

      await tester.tap(chip);
      await tester.pumpAndSettle();

      final campo = tester.widget<TextField>(find.byType(TextField));
      expect(campo.controller!.text, 'Ansioso');
    });

    testWidgets('respeta lo ya escrito sin pisarlo', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      await tester.enterText(_campoObservacion(), 'Estuvo tranquila');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Con energía'));
      await tester.pumpAndSettle();

      final campo = tester.widget<TextField>(find.byType(TextField));
      expect(campo.controller!.text, 'Estuvo tranquila. Con energía');
      // El cursor queda al final, listo para seguir escribiendo.
      expect(
        campo.controller!.selection.baseOffset,
        'Estuvo tranquila. Con energía'.length,
      );
    });

    testWidgets('si el texto ya termina en punto no agrega otro', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      await tester.enterText(_campoObservacion(), 'Estuvo tranquila.');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Con energía'));
      await tester.pumpAndSettle();

      final campo = tester.widget<TextField>(find.byType(TextField));
      expect(campo.controller!.text, 'Estuvo tranquila. Con energía');
    });
  });

  group('MoodFormScreen · último registro', () {
    testWidgets('sin registro de hoy el pie no se dibuja', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.textContaining('Último registro'), findsNothing);
    });

    testWidgets('con registro de hoy muestra hora y descripción', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(animoHoy: _animoDeHoy));
      await tester.pumpAndSettle();

      expect(find.textContaining('Último registro: hoy'), findsOneWidget);
      expect(find.textContaining('Muy bien'), findsWidgets);
    });

    testWidgets('el registro de hoy no precarga el formulario', (tester) async {
      // Registrar sobrescribe: el pie avisa, pero el formulario arranca
      // limpio para no dar por hecho que se repite el mismo estado.
      await tester.pumpWidget(_wrap(animoHoy: _animoDeHoy));
      await tester.pumpAndSettle();

      final selector = tester.widget<MoodScaleSelector>(
        find.byType(MoodScaleSelector),
      );
      expect(selector.selectedLevel, isNull);
      expect(_cta(tester).onPressed, isNull);
      expect(find.text('Registrar estado'), findsOneWidget);
    });
  });

  group('MoodFormScreen · robustez de layout', () {
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
          _wrap(
            animoHoy: _animoDeHoy,
            textScaler: const TextScaler.linear(1.6),
            themeMode: themeMode,
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);

        await tester.tap(find.text('Muy bien').first);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  });
}
