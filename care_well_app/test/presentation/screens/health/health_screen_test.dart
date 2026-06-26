import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/screens/screens.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final _personaMaria = Persona(
  id: 1,
  nombre: 'María',
  apellido: 'García',
  documento: '28000001',
  fechaNacimiento: DateTime(1990, 1, 1),
);

final _personaAlicia = Persona(
  id: 2,
  nombre: 'Alicia',
  apellido: 'Rodríguez',
  documento: '5234100',
  fechaNacimiento: DateTime(1943, 7, 22),
);

Widget _wrap({Persona? persona}) {
  final personaEfectiva = persona ?? _personaAlicia;
  return ProviderScope(
    overrides: [
      healthPersonaContextProvider.overrideWith((ref) async => personaEfectiva),
      // ContextSelector necesita estos providers.
      careTeamContextPersonaProvider.overrideWith(
        (ref) async => personaEfectiva,
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
    ],
    child: const MaterialApp(home: HealthScreen()),
  );
}

void main() {
  group('HealthScreen', () {
    testWidgets('smoke: renderiza sin errores', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(HealthScreen), findsOneWidget);
    });

    testWidgets('muestra ContextSelector con nombre de persona', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();
      expect(find.byType(ContextSelector), findsOneWidget);
      expect(find.textContaining('Alicia Rodríguez'), findsOneWidget);
    });

    testWidgets('muestra tiles de categorías', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(HealthCategoryCard), findsWidgets);
      expect(find.text('Hábitos de vida'), findsOneWidget);
      expect(find.text('Eventos de salud'), findsOneWidget);
    });

    testWidgets('sin persona muestra mensaje de estado vacío', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            healthPersonaContextProvider.overrideWith((ref) async => null),
            careTeamContextPersonaProvider.overrideWith((ref) async => null),
            personasSeleccionablesProvider.overrideWith((ref) async => []),
          ],
          child: const MaterialApp(home: HealthScreen()),
        ),
      );
      await tester.pump();
      expect(find.textContaining('persona a cargo'), findsOneWidget);
    });
  });
}
