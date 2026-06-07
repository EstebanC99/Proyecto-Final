import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// ─── Fixtures ─────────────────────────────────────────────────────────────────

final _personaMaria = Persona(
  id: 'per_001',
  nombre: 'María',
  apellido: 'García',
  email: 'maria@test.com',
);

final _personaAlicia = Persona(
  id: 'per_002',
  nombre: 'Alicia',
  apellido: 'Rodríguez',
);

// ─── Helpers ──────────────────────────────────────────────────────────────────

/// Envuelve [child] con [ProviderScope] y [MaterialApp].
Widget _wrap(Widget child, {List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

/// Construye overrides con una sola persona seleccionable (el propio usuario).
List<Override> _solaUnaOpcion() => [
  careTeamContextPersonaProvider.overrideWith((ref) async => _personaMaria),
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
List<Override> _variosOpciones({String? selectedId}) => [
  careTeamContextPersonaProvider.overrideWith(
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
      'al seleccionar una opción en el sheet se actualiza selectedPersonaIdProvider',
      (tester) async {
        late ProviderContainer container;

        await tester.pumpWidget(
          ProviderScope(
            overrides: _variosOpciones(),
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

        expect(container.read(selectedPersonaIdProvider), _personaAlicia.id);
      },
    );

    testWidgets('con persona nula no renderiza ningún chip', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ContextSelector(),
          overrides: [
            careTeamContextPersonaProvider.overrideWith((ref) async => null),
            personasSeleccionablesProvider.overrideWith((ref) async => []),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ContextChip), findsNothing);
    });
  });
}
