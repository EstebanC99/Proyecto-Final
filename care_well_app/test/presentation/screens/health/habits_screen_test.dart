import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/screens/screens.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
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

/// Hábito ya realizado hoy: cae en la sección "Completados".
HabitoVida _realizado(int id, String descripcion) => HabitoVida(
  id: id,
  persona: EntidadBasica(id: 2, descripcion: 'Alicia Rodríguez'),
  tipo: tipoHabitoAlimentacion,
  descripcion: descripcion,
  realizacion: RealizacionHabitoVida(
    id: id * 10,
    habitoId: id,
    fechaHora: DateTime.now(),
  ),
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

/// `InkWell` del círculo de check del hábito con [habitoId].
InkWell _checkInkWell(WidgetTester tester, int habitoId) {
  return tester.widget<InkWell>(
    find.descendant(
      of: find.byKey(ValueKey('habito-check-$habitoId')),
      matching: find.byType(InkWell),
    ),
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
      // Sin hábitos no hay progreso que mostrar.
      expect(find.byType(HabitsDayProgressHeader), findsNothing);
    });

    testWidgets(
      'el estado vacío no menciona el botón + si no puede registrar',
      (tester) async {
        await tester.pumpWidget(_wrap(habitos: [], puedeRegistrar: false));
        await tester.pump();
        expect(find.text('Sin hábitos registrados'), findsOneWidget);
        expect(find.textContaining('botón +'), findsNothing);
      },
    );

    testWidgets('muestra la banda de progreso del día', (tester) async {
      await tester.pumpWidget(
        _wrap(habitos: [_habito, _realizado(902, 'Desayuno completo')]),
      );
      await tester.pump();

      expect(find.byType(HabitsDayProgressHeader), findsOneWidget);
      expect(find.text('1 de 2'), findsOneWidget);
    });

    testWidgets('agrupa en pendientes y completados con sus contadores', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          habitos: [
            _habito,
            _realizado(902, 'Desayuno completo'),
            _realizado(903, 'Almuerzo liviano'),
          ],
        ),
      );
      await tester.pump();

      expect(find.text('PENDIENTES · 1'), findsOneWidget);
      expect(find.text('COMPLETADOS · 2'), findsOneWidget);
    });

    testWidgets('no renderiza la sección "Pendientes" si están todos hechos', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(habitos: [_realizado(902, 'Desayuno completo')]),
      );
      await tester.pump();

      expect(find.textContaining('PENDIENTES'), findsNothing);
      expect(find.text('COMPLETADOS · 1'), findsOneWidget);
    });

    testWidgets('no renderiza la sección "Completados" si no hay ninguno', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      expect(find.text('PENDIENTES · 1'), findsOneWidget);
      expect(find.textContaining('COMPLETADOS'), findsNothing);
    });

    testWidgets(
      'marcar realizado disponible para miembro del equipo aunque NO pueda '
      'registrar (ABM)',
      (tester) async {
        await tester.pumpWidget(
          _wrap(puedeRegistrar: false, esMiembroEquipo: true),
        );
        await tester.pumpAndSettle();
        // El FAB de ABM permanece oculto (sigue gateado por el permiso).
        expect(find.byType(FloatingActionButton), findsNothing);
        // Pero el registro de cumplimiento diario sí es accionable.
        await tester.tap(find.byKey(const ValueKey('habito-check-901')));
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
        await tester.pumpAndSettle();
        // El check se muestra pero no es accionable (onTap nulo).
        expect(_checkInkWell(tester, 901).onTap, isNull);
      },
    );
  });
}
