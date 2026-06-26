import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../_fakes/test_fixtures.dart';

final _personaAlicia = Persona(
  id: 2,
  nombre: 'Alicia',
  apellido: 'Rodríguez',
  documento: '5234100',
  fechaNacimiento: DateTime(1943, 7, 22),
);

final _habito = HabitoDeVida(
  id: 901,
  persona: _personaAlicia,
  tipo: tipoHabitoActividadFisica,
  descripcion: 'Caminata diaria',
);

Widget _wrap({List<HabitoDeVida>? habitos, bool puedeRegistrar = true}) {
  return ProviderScope(
    overrides: [
      habitosProvider.overrideWith((ref) async => habitos ?? [_habito]),
      puedeRegistrarHabitosProvider.overrideWith((ref) async => puedeRegistrar),
    ],
    child: const MaterialApp(home: HabitsScreen()),
  );
}

void main() {
  group('HabitsScreen', () {
    testWidgets('smoke: renderiza sin errores', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(HabitsScreen), findsOneWidget);
    });

    testWidgets('FAB visible si puede registrar', (tester) async {
      await tester.pumpWidget(_wrap(puedeRegistrar: true));
      await tester.pump();
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('FAB NO visible si no puede registrar', (tester) async {
      await tester.pumpWidget(_wrap(puedeRegistrar: false));
      await tester.pump();
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('muestra estado vacío cuando no hay hábitos', (tester) async {
      await tester.pumpWidget(_wrap(habitos: []));
      await tester.pump();
      expect(find.text('Sin hábitos registrados'), findsOneWidget);
    });
  });
}
