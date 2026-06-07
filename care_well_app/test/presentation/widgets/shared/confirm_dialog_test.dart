import 'package:care_well_app/presentation/widgets/shared/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('ConfirmDialog', () {
    testWidgets('muestra el título y el cuerpo correctamente', (tester) async {
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () => ConfirmDialog.show(
                ctx,
                title: 'Título de prueba',
                body: 'Cuerpo de prueba',
                confirmLabel: 'Confirmar',
                onConfirm: () async {},
              ),
              child: const Text('Abrir'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      expect(find.text('Título de prueba'), findsOneWidget);
      expect(find.text('Cuerpo de prueba'), findsOneWidget);
    });

    testWidgets('muestra el botón con la etiqueta de confirmación', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () => ConfirmDialog.show(
                ctx,
                title: 'Eliminar',
                body: 'Esta acción no se puede deshacer.',
                confirmLabel: 'Eliminar',
                onConfirm: () async {},
              ),
              child: const Text('Abrir'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      expect(find.text('Eliminar'), findsWidgets);
      expect(find.text('Cancelar'), findsOneWidget);
    });

    testWidgets('presionar Cancelar cierra el diálogo y retorna false', (
      tester,
    ) async {
      bool? resultado;

      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () async {
                resultado = await ConfirmDialog.show(
                  ctx,
                  title: '¿Eliminar?',
                  body: 'Esta acción no se puede deshacer.',
                  confirmLabel: 'Eliminar',
                  onConfirm: () async {},
                );
              },
              child: const Text('Abrir'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(resultado, isFalse);
      expect(find.text('Cancelar'), findsNothing);
    });

    testWidgets('presionar confirmar ejecuta onConfirm y retorna true', (
      tester,
    ) async {
      bool ejecutado = false;
      bool? resultado;

      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () async {
                resultado = await ConfirmDialog.show(
                  ctx,
                  title: '¿Quitar?',
                  body: 'El miembro perderá acceso.',
                  confirmLabel: 'Quitar',
                  onConfirm: () async {
                    ejecutado = true;
                  },
                );
              },
              child: const Text('Abrir'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      // Hay dos textos "Quitar" (título y botón). Usamos el botón FilledButton.
      final filledButtons = find.byType(FilledButton);
      await tester.tap(filledButtons.first);
      await tester.pumpAndSettle();

      expect(ejecutado, isTrue);
      expect(resultado, isTrue);
    });

    testWidgets('acepta un ícono personalizado', (tester) async {
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () => ConfirmDialog.show(
                ctx,
                title: 'Título',
                body: 'Cuerpo',
                confirmLabel: 'OK',
                onConfirm: () async {},
                icon: Icons.delete_outline,
              ),
              child: const Text('Abrir'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });
  });
}
