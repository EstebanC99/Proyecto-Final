import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../_fakes/test_fixtures.dart';

final _habito = HabitoVida(
  id: 901,
  persona: EntidadBasica(id: 2, descripcion: 'Alicia Rodríguez'),
  tipo: tipoHabitoActividadFisica,
  descripcion: 'Caminata diaria',
);

Widget _wrap({
  List<HabitoVida>? habitos,
  bool puedeRegistrar = true,
  bool esMiembroEquipo = true,
}) {
  return ProviderScope(
    overrides: [
      habitosProvider.overrideWith((ref) async => habitos ?? [_habito]),
      puedeRegistrarHabitosProvider.overrideWith((ref) async => puedeRegistrar),
      esMiembroEquipoActivoProvider.overrideWith(
        (ref) async => esMiembroEquipo,
      ),
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

    testWidgets(
      'marcar realizado disponible para miembro del equipo aunque NO pueda '
      'registrar (ABM)',
      (tester) async {
        await tester.pumpWidget(
          _wrap(puedeRegistrar: false, esMiembroEquipo: true),
        );
        await tester.pump();
        // El FAB de ABM permanece oculto (sigue gateado por el permiso).
        expect(find.byType(FloatingActionButton), findsNothing);
        // Pero el registro de cumplimiento diario sí es accionable.
        await tester.tap(find.text('Pendiente'));
        await tester.pumpAndSettle();
        expect(
          find.text('Podés agregar un comentario opcional.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'marcar realizado NO disponible si no es miembro activo del equipo',
      (tester) async {
        await tester.pumpWidget(
          _wrap(puedeRegistrar: false, esMiembroEquipo: false),
        );
        await tester.pump();
        // El chip de realización no es accionable (onTap nulo): tapearlo no
        // dispara el sheet de cumplimiento.
        final gesture = tester.widget<GestureDetector>(
          find
              .ancestor(
                of: find.text('Pendiente'),
                matching: find.byType(GestureDetector),
              )
              .first,
        );
        expect(gesture.onTap, isNull);
      },
    );
  });
}
