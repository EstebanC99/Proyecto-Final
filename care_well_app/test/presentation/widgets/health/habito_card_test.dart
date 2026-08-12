import 'dart:ui' show CheckedState;

import 'package:care_well_app/config/theme/app_palette.dart';
import 'package:care_well_app/config/theme/app_theme.dart';
import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../_fakes/test_fixtures.dart';

final _pendiente = HabitoVida(
  id: 901,
  persona: refPersonaAlicia,
  tipo: tipoHabitoActividadFisica,
  descripcion: 'Caminata diaria',
);

final _realizado = HabitoVida(
  id: 902,
  persona: refPersonaAlicia,
  tipo: tipoHabitoAlimentacion,
  descripcion: 'Desayuno completo',
  realizacion: RealizacionHabitoVida(
    id: 1,
    habitoId: 902,
    fechaHora: DateTime(2026, 8, 12, 9),
  ),
);

Widget _wrap(HabitoVida habito, {VoidCallback? onToggle, VoidCallback? onTap}) {
  return MaterialApp(
    theme: AppTheme().light,
    home: Scaffold(
      body: HabitoCard(
        habito: habito,
        onTap: onTap ?? () {},
        onToggleRealizacion: onToggle,
      ),
    ),
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
  group('HabitoCard', () {
    testWidgets('muestra categoría en versales y descripción', (tester) async {
      await tester.pumpWidget(_wrap(_pendiente));
      expect(find.text('ACTIVIDAD FÍSICA'), findsOneWidget);
      expect(find.text('Caminata diaria'), findsOneWidget);
    });

    testWidgets('pendiente: círculo vacío y descripción sin tachar', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(_pendiente));

      expect(find.byIcon(Icons.check), findsNothing);
      final texto = tester.widget<Text>(find.text('Caminata diaria'));
      expect(texto.style?.decoration, isNot(TextDecoration.lineThrough));
    });

    testWidgets('realizado: check relleno y descripción tachada', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(_realizado));

      expect(find.byIcon(Icons.check), findsOneWidget);
      final texto = tester.widget<Text>(find.text('Desayuno completo'));
      expect(texto.style?.decoration, TextDecoration.lineThrough);
    });

    testWidgets('el check dispara onToggleRealizacion sin navegar al detalle', (
      tester,
    ) async {
      var toggles = 0;
      var taps = 0;
      await tester.pumpWidget(
        _wrap(_pendiente, onToggle: () => toggles++, onTap: () => taps++),
      );

      await tester.tap(find.byKey(const ValueKey('habito-check-901')));
      await tester.pumpAndSettle();

      expect(toggles, 1);
      expect(taps, 0);
    });

    testWidgets('sin onToggleRealizacion el check no es accionable', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(_pendiente));
      expect(find.byKey(const ValueKey('habito-check-901')), findsOneWidget);
      expect(_checkInkWell(tester, 901).onTap, isNull);
    });

    testWidgets('el check expone su estado en la semántica', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(_wrap(_realizado, onToggle: () {}));
      final marcado = tester
          .getSemantics(find.byKey(const ValueKey('habito-check-902')))
          .flagsCollection;
      expect(marcado.isButton, isTrue);
      expect(marcado.isChecked, CheckedState.isTrue);

      await tester.pumpWidget(_wrap(_pendiente, onToggle: () {}));
      final pendiente = tester
          .getSemantics(find.byKey(const ValueKey('habito-check-901')))
          .flagsCollection;
      expect(pendiente.isChecked, CheckedState.isFalse);

      handle.dispose();
    });

    testWidgets('el check describe la acción en la semántica', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap(_realizado, onToggle: () {}));

      expect(
        find.bySemanticsLabel('Marcar Desayuno completo como realizado'),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('la card realizada usa el fondo atenuado', (tester) async {
      await tester.pumpWidget(_wrap(_realizado));

      final context = tester.element(find.byType(HabitoCard));
      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.color, context.colors.surfaceVariant);
    });
  });
}
