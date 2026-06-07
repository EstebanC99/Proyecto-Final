import 'package:care_well_app/presentation/widgets/care_team/permission_toggle_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('PermissionToggleRow', () {
    testWidgets('renderiza sin errores (smoke)', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PermissionToggleRow(
            label: 'Ver ficha de salud',
            value: false,
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.byType(PermissionToggleRow), findsOneWidget);
    });

    testWidgets('muestra el label correctamente', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PermissionToggleRow(
            label: 'Gestionar agenda',
            value: false,
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('Gestionar agenda'), findsOneWidget);
    });

    testWidgets('Switch está activo cuando value es true', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PermissionToggleRow(
            label: 'Permiso activo',
            value: true,
            onChanged: (_) {},
          ),
        ),
      );

      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isTrue);
    });

    testWidgets('Switch está inactivo cuando value es false', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PermissionToggleRow(
            label: 'Permiso inactivo',
            value: false,
            onChanged: (_) {},
          ),
        ),
      );

      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isFalse);
    });

    testWidgets('tap en la fila llama onChanged con el valor invertido', (
      tester,
    ) async {
      bool? valorRecibido;

      await tester.pumpWidget(
        _wrap(
          PermissionToggleRow(
            label: 'Ver salud',
            value: false,
            onChanged: (v) => valorRecibido = v,
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      expect(valorRecibido, isTrue);
    });

    testWidgets('tap en Switch llama onChanged', (tester) async {
      bool? valorRecibido;

      await tester.pumpWidget(
        _wrap(
          PermissionToggleRow(
            label: 'Activar emergencia',
            value: true,
            onChanged: (v) => valorRecibido = v,
          ),
        ),
      );

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(valorRecibido, isNotNull);
    });

    testWidgets('tiene altura mínima de 56 dp', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PermissionToggleRow(
            label: 'Registrar hábitos',
            value: false,
            onChanged: (_) {},
          ),
        ),
      );

      final inkWell = tester.getSize(find.byType(InkWell));
      expect(inkWell.height, greaterThanOrEqualTo(56));
    });
  });
}
