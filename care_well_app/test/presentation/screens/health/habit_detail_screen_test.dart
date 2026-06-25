import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../_fakes/test_fixtures.dart';

// ─── Fixtures ─────────────────────────────────────────────────────────────────

final _personaAlicia = Persona(id: 2, nombre: 'Alicia', apellido: 'Rodríguez');

final _habito = HabitoDeVida(
  id: 901,
  persona: _personaAlicia,
  tipo: tipoHabitoActividadFisica,
  descripcion: 'Caminata diaria de 30 minutos.',
);

// ─── Helpers ──────────────────────────────────────────────────────────────────

// Centinela para distinguir "usar el hábito por defecto" de "devolver null".
const _sinHabito = Object();

Widget _wrap({
  Object? habito = _sinHabito,
  bool puedeRegistrar = true,
  int habitId = 901,
}) {
  final habitoResuelto = habito == _sinHabito
      ? _habito
      : habito as HabitoDeVida?;
  return ProviderScope(
    overrides: [
      habitoByIdProvider(habitId).overrideWith((ref) async => habitoResuelto),
      puedeRegistrarHabitosProvider.overrideWith((ref) async => puedeRegistrar),
      // eliminarHabitoProvider no necesita override para smoke tests.
    ],
    child: MaterialApp(home: HabitDetailScreen(habitId: habitId)),
  );
}

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('HabitDetailScreen', () {
    testWidgets('smoke: renderiza sin errores', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(HabitDetailScreen), findsOneWidget);
    });

    testWidgets('muestra la descripción del hábito', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Caminata diaria de 30 minutos.'), findsOneWidget);
    });

    testWidgets(
      'muestra botón editar y botón eliminar cuando puede registrar',
      (tester) async {
        await tester.pumpWidget(_wrap(puedeRegistrar: true));
        await tester.pump();
        expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
        expect(find.byIcon(Icons.delete_outline), findsOneWidget);
      },
    );

    testWidgets(
      'NO muestra botón editar ni eliminar cuando NO puede registrar',
      (tester) async {
        await tester.pumpWidget(_wrap(puedeRegistrar: false));
        await tester.pump();
        expect(find.byIcon(Icons.edit_outlined), findsNothing);
        expect(find.byIcon(Icons.delete_outline), findsNothing);
      },
    );

    testWidgets('muestra mensaje cuando el hábito no existe', (tester) async {
      await tester.pumpWidget(_wrap(habito: null, habitId: 99999));
      await tester.pump();
      expect(find.text('Hábito no encontrado.'), findsOneWidget);
    });
  });
}
