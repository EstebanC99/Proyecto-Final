import 'dart:async';

import 'package:care_well_app/config/theme/app_spacing.dart';
import 'package:care_well_app/config/theme/app_theme.dart';
import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

// ─── Fixtures ─────────────────────────────────────────────────────────────────

final _personaMaria = Persona(
  id: 1,
  nombre: 'María',
  apellido: 'García',
  documento: '28000001',
  fechaNacimiento: DateTime(1990, 1, 1),
  email: 'maria@test.com',
);

final _personaAlicia = Persona(
  id: 2,
  nombre: 'Alicia',
  apellido: 'Rodríguez',
  documento: '5234100',
  fechaNacimiento: DateTime(1943, 7, 22),
);

// ─── Helpers ──────────────────────────────────────────────────────────────────

/// Monta un [Scaffold] con [ContextAppBar] como barra superior.
///
/// Incluye el override de [personaImagenProvider] a `null` para que los
/// [PersonaAvatar] caigan al fallback de iniciales sin golpear el repositorio.
Widget _wrap({
  List<Override> overrides = const [],
  String eyebrow = 'Salud',
  List<Widget> actions = const [],
  ThemeMode themeMode = ThemeMode.light,
  bool seleccionable = true,
}) {
  return ProviderScope(
    overrides: [
      personaImagenProvider.overrideWith((ref, id) async => null),
      ...overrides,
    ],
    child: MaterialApp(
      themeMode: themeMode,
      theme: AppTheme().light,
      darkTheme: AppTheme().dark,
      home: Scaffold(
        appBar: ContextAppBar(
          eyebrow: eyebrow,
          actions: actions,
          seleccionable: seleccionable,
        ),
        body: const SizedBox.expand(),
      ),
    ),
  );
}

/// Overrides con una sola persona seleccionable (el propio usuario).
List<Override> _solaUnaOpcion() => [
  personaVisualizacionSeleccionadaProvider.overrideWith(
    (ref) async => _personaMaria,
  ),
  personasSeleccionablesProvider.overrideWith(
    (ref) async => [
      PersonaContextOption(
        persona: _personaMaria,
        rol: PersonaContextRol.propio,
      ),
    ],
  ),
];

/// Overrides con dos personas seleccionables.
List<Override> _variosOpciones({int? selectedId}) => [
  personaVisualizacionSeleccionadaProvider.overrideWith(
    (ref) async =>
        selectedId == _personaAlicia.id ? _personaAlicia : _personaMaria,
  ),
  personasSeleccionablesProvider.overrideWith(
    (ref) async => [
      PersonaContextOption(
        persona: _personaMaria,
        rol: PersonaContextRol.propio,
      ),
      PersonaContextOption(
        persona: _personaAlicia,
        rol: PersonaContextRol.responsable,
      ),
    ],
  ),
];

/// Overrides sin persona de contexto (usuario sin personas a cargo).
List<Override> _sinPersona() => [
  personaVisualizacionSeleccionadaProvider.overrideWith((ref) async => null),
  personasSeleccionablesProvider.overrideWith((ref) async => []),
];

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('ContextAppBar', () {
    testWidgets('renderiza el rótulo en versales, el nombre y el badge', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(overrides: _solaUnaOpcion()));
      await tester.pumpAndSettle();

      expect(find.text('SALUD'), findsOneWidget);
      expect(find.text('María García'), findsOneWidget);
      expect(find.text('YO'), findsOneWidget);
    });

    testWidgets('con una sola opción no muestra chevron ni abre el sheet', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(overrides: _solaUnaOpcion()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.expand_more), findsNothing);

      await tester.tap(find.byType(ContextSelector));
      await tester.pumpAndSettle();

      expect(find.text('Visualizando a'), findsNothing);
    });

    testWidgets('con varias opciones el tap abre el bottom sheet', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(overrides: _variosOpciones()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.expand_more), findsOneWidget);

      await tester.tap(find.byType(ContextSelector));
      await tester.pumpAndSettle();

      expect(find.text('Visualizando a'), findsOneWidget);
      expect(find.text('Alicia Rodríguez'), findsAtLeastNWidgets(1));
    });

    testWidgets('no muestra mini-avatares de las otras personas', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(overrides: _variosOpciones()));
      await tester.pumpAndSettle();

      // Solo el avatar de la persona de contexto (en `compact` serían 2).
      expect(find.byType(PersonaAvatar), findsOneWidget);
    });

    testWidgets('sin persona de contexto el rótulo sigue visible', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(overrides: _sinPersona()));
      await tester.pumpAndSettle();

      expect(find.text('SALUD'), findsOneWidget);
      expect(find.byType(PersonaAvatar), findsNothing);
    });

    testWidgets('mientras carga la persona el rótulo sigue visible', (
      tester,
    ) async {
      // Future que nunca completa: el provider queda en `loading`.
      final pendiente = Completer<Persona?>();

      await tester.pumpWidget(
        _wrap(
          overrides: [
            personaVisualizacionSeleccionadaProvider.overrideWith(
              (ref) => pendiente.future,
            ),
            personasSeleccionablesProvider.overrideWith((ref) async => []),
          ],
        ),
      );
      await tester.pump();

      expect(find.text('SALUD'), findsOneWidget);
      // Placeholder del nombre mientras se resuelve la persona.
      expect(find.byType(PersonaAvatar), findsNothing);
    });

    testWidgets('el badge de rol se abrevia (RESP.)', (tester) async {
      await tester.pumpWidget(
        _wrap(overrides: _variosOpciones(selectedId: _personaAlicia.id)),
      );
      await tester.pumpAndSettle();

      expect(find.text('RESP.'), findsOneWidget);
      expect(find.text('Responsable'), findsNothing);
    });

    testWidgets('con escala tipográfica 2.0 crece y no desborda', (
      tester,
    ) async {
      // La escala se fija a nivel plataforma porque de ahí la lee el widget
      // para declarar su `preferredSize` (ver doc de ContextAppBar).
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpWidget(
        _wrap(
          overrides: _variosOpciones(selectedId: _personaAlicia.id),
          eyebrow: 'Historial de ánimo',
          actions: [
            IconButton(icon: const Icon(Icons.refresh), onPressed: () {}),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byType(AppBar)).height,
        greaterThan(AppSpacing.appBarHeight),
      );
    });

    testWidgets('con escala tipográfica normal mide el alto estándar', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(overrides: _solaUnaOpcion()));
      await tester.pumpAndSettle();

      // El body arranca justo debajo: sin franja vacía bajo el título.
      expect(
        tester.getSize(find.byType(AppBar)).height,
        AppSpacing.appBarHeight,
      );
    });

    testWidgets('en tema oscuro monta sin excepciones', (tester) async {
      await tester.pumpWidget(
        _wrap(overrides: _solaUnaOpcion(), themeMode: ThemeMode.dark),
      );
      await tester.pumpAndSettle();

      expect(find.text('SALUD'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('el título se anuncia como header accesible', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _wrap(overrides: _variosOpciones(selectedId: _personaAlicia.id)),
      );
      await tester.pumpAndSettle();

      // El lector de pantalla recibe la sección en su forma natural (no en
      // versales) más la persona y el rol en palabras completas.
      expect(
        find.bySemanticsLabel('Salud, viendo a Alicia Rodríguez, responsable'),
        findsOneWidget,
      );

      handle.dispose();
    });

    testWidgets('con seleccionable: false el título queda inerte', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(overrides: _variosOpciones(), seleccionable: false),
      );
      await tester.pumpAndSettle();

      // Sigue mostrando a la persona, pero sin chevron ni bottom sheet.
      expect(find.text('María García'), findsOneWidget);
      expect(find.byIcon(Icons.expand_more), findsNothing);

      await tester.tap(find.byType(ContextSelector));
      await tester.pumpAndSettle();

      expect(find.text('Visualizando a'), findsNothing);
    });
  });
}
