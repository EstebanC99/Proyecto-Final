import 'package:care_well_app/config/theme/app_palette.dart';
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

/// Envuelve [child] con [ProviderScope] y [MaterialApp].
///
/// Incluye por defecto un override de [personaImagenProvider] a `null`, para
/// que los [PersonaAvatar] del banner caigan al fallback de iniciales sin
/// golpear el repositorio real.
Widget _wrap(Widget child, {List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: [
      personaImagenProvider.overrideWith((ref, id) async => null),
      ...overrides,
    ],
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

/// Construye overrides con una sola persona seleccionable (el propio usuario).
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

/// Construye overrides con dos personas seleccionables.
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

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('ContextSelector', () {
    testWidgets('smoke: renderiza sin errores con una sola persona', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const ContextSelector(), overrides: _solaUnaOpcion()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ContextSelector), findsOneWidget);
    });

    testWidgets('con una sola opción no muestra ícono expand_more', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const ContextSelector(), overrides: _solaUnaOpcion()),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.expand_more), findsNothing);
    });

    testWidgets('con una sola opción muestra el subtítulo "Yo"', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const ContextSelector(), overrides: _solaUnaOpcion()),
      );
      await tester.pumpAndSettle();

      // El banner muestra "Yo" como subtítulo cuando la persona es el propio usuario.
      expect(find.text('Yo'), findsOneWidget);
    });

    testWidgets('con múltiples opciones muestra ícono expand_more', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const ContextSelector(), overrides: _variosOpciones()),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.expand_more), findsOneWidget);
    });

    testWidgets('al tap abre el bottom sheet con el título "Visualizando a"', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const ContextSelector(), overrides: _variosOpciones()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ContextSelector));
      await tester.pumpAndSettle();

      expect(find.text('Visualizando a'), findsOneWidget);
    });

    testWidgets('el bottom sheet lista todas las opciones disponibles', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const ContextSelector(), overrides: _variosOpciones()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ContextSelector));
      await tester.pumpAndSettle();

      // El nombre puede aparecer tanto en el banner como en el sheet.
      expect(find.text('María García'), findsAtLeastNWidgets(1));
      expect(find.text('Alicia Rodríguez'), findsAtLeastNWidgets(1));
    });

    testWidgets(
      'al seleccionar una opción en el sheet se actualiza personaVisualizacionSeleccionadaIdProvider',
      (tester) async {
        late ProviderContainer container;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              personaImagenProvider.overrideWith((ref, id) async => null),
              ..._variosOpciones(),
            ],
            child: Consumer(
              builder: (context, ref, _) {
                // Capturamos el container a través del Consumer.
                container = ProviderScope.containerOf(context);
                return const MaterialApp(
                  home: Scaffold(body: ContextSelector()),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Abrir el sheet.
        await tester.tap(find.byType(ContextSelector));
        await tester.pumpAndSettle();

        // Tap sobre Alicia Rodríguez en el sheet.
        await tester.tap(find.text('Alicia Rodríguez'));
        await tester.pumpAndSettle();

        expect(
          container.read(personaVisualizacionSeleccionadaIdProvider),
          _personaAlicia.id,
        );
      },
    );

    testWidgets('el banner se dibuja con borde primary sobre superficie', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const ContextSelector(), overrides: _solaUnaOpcion()),
      );
      await tester.pumpAndSettle();

      // Único contenedor rectangular con borde del árbol del banner.
      final decoracion = tester
          .widgetList<Container>(find.byType(Container))
          .map((c) => c.decoration)
          .whereType<BoxDecoration>()
          .singleWhere(
            (d) => d.border != null && d.shape == BoxShape.rectangle,
          );

      expect(decoracion.color, AppPalette.light.surface);
      expect(
        decoracion.border,
        Border.all(color: AppPalette.light.primary, width: 1.5),
      );
    });

    testWidgets('con persona nula no renderiza ningún chip', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ContextSelector(),
          overrides: [
            personaVisualizacionSeleccionadaProvider.overrideWith(
              (ref) async => null,
            ),
            personasSeleccionablesProvider.overrideWith((ref) async => []),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ContextChip), findsNothing);
    });

    // ─── Variante compacta (Home y Agenda) ────────────────────────────────────

    group('variant: compact', () {
      const compacto = ContextSelector(variant: ContextSelectorVariant.compact);

      testWidgets('smoke: renderiza el banner compacto con una sola persona', (
        tester,
      ) async {
        await tester.pumpWidget(_wrap(compacto, overrides: _solaUnaOpcion()));
        await tester.pumpAndSettle();

        expect(find.byType(ContextCompactBanner), findsOneWidget);
        expect(find.byType(ContextChip), findsNothing);
      });

      testWidgets('muestra el rótulo por defecto y el badge de rol "YO"', (
        tester,
      ) async {
        await tester.pumpWidget(_wrap(compacto, overrides: _solaUnaOpcion()));
        await tester.pumpAndSettle();

        expect(find.text('ESTÁS VIENDO'), findsOneWidget);
        expect(find.text('YO'), findsOneWidget);
        expect(find.text('María García'), findsOneWidget);
      });

      testWidgets('el rótulo se puede personalizar por pantalla', (
        tester,
      ) async {
        await tester.pumpWidget(
          _wrap(
            const ContextSelector(
              variant: ContextSelectorVariant.compact,
              eyebrow: 'Calendario',
            ),
            overrides: _solaUnaOpcion(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('CALENDARIO'), findsOneWidget);
      });

      testWidgets('con una sola opción no muestra chevron ni mini-avatares', (
        tester,
      ) async {
        await tester.pumpWidget(_wrap(compacto, overrides: _solaUnaOpcion()));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.expand_more), findsNothing);
        // Solo el avatar de la persona de contexto.
        expect(find.byType(PersonaAvatar), findsOneWidget);
      });

      testWidgets('con múltiples opciones muestra chevron y mini-avatares', (
        tester,
      ) async {
        await tester.pumpWidget(_wrap(compacto, overrides: _variosOpciones()));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.expand_more), findsOneWidget);
        // Avatar de contexto + mini-avatar de la otra persona.
        expect(find.byType(PersonaAvatar), findsNWidgets(2));
      });

      testWidgets('muestra el badge de rol de una persona a cargo', (
        tester,
      ) async {
        await tester.pumpWidget(
          _wrap(
            compacto,
            overrides: _variosOpciones(selectedId: _personaAlicia.id),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Responsable'), findsOneWidget);
        expect(find.text('YO'), findsNothing);
      });

      testWidgets(
        'al tap abre el mismo bottom sheet que la variante estándar',
        (tester) async {
          await tester.pumpWidget(
            _wrap(compacto, overrides: _variosOpciones()),
          );
          await tester.pumpAndSettle();

          await tester.tap(find.byType(ContextSelector));
          await tester.pumpAndSettle();

          expect(find.text('Visualizando a'), findsOneWidget);
          expect(find.text('Alicia Rodríguez'), findsAtLeastNWidgets(1));
        },
      );

      testWidgets('con persona nula no renderiza el banner compacto', (
        tester,
      ) async {
        await tester.pumpWidget(
          _wrap(
            compacto,
            overrides: [
              personaVisualizacionSeleccionadaProvider.overrideWith(
                (ref) async => null,
              ),
              personasSeleccionablesProvider.overrideWith((ref) async => []),
            ],
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(ContextCompactBanner), findsNothing);
      });
    });
  });
}
