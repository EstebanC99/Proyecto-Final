import 'package:care_well_app/config/theme/app_theme.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// Monta la pantalla protegida como ruta apilada, para que haya a dónde
  /// volver al salir.
  Future<void> pushProtegida(
    WidgetTester tester, {
    required bool Function() hayCambios,
    VoidCallback? onGuardar,
  }) async {
    final navKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navKey,
        theme: AppTheme().light,
        home: const Scaffold(body: Center(child: Text('pantalla anterior'))),
      ),
    );
    navKey.currentState!.push(
      MaterialPageRoute(
        builder: (_) => UnsavedChangesGuard(
          hayCambios: hayCambios,
          child: Scaffold(
            appBar: AppBar(title: const Text('Formulario')),
            body: Center(
              child: TextButton(
                onPressed: onGuardar,
                child: const Text('Guardar'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Dispara el gesto de "atrás" del sistema.
  Future<void> volverAtras(WidgetTester tester) async {
    final dynamic estado = tester.state(find.byType(WidgetsApp));
    await estado.didPopRoute();
    await tester.pumpAndSettle();
  }

  group('UnsavedChangesGuard', () {
    testWidgets('sin cambios el atrás cierra sin preguntar', (tester) async {
      await pushProtegida(tester, hayCambios: () => false);

      await volverAtras(tester);

      expect(find.text('Tenés cambios sin guardar'), findsNothing);
      expect(find.text('pantalla anterior'), findsOneWidget);
    });

    testWidgets('con cambios el atrás pide confirmación', (tester) async {
      await pushProtegida(tester, hayCambios: () => true);

      await volverAtras(tester);

      expect(find.text('Tenés cambios sin guardar'), findsOneWidget);
      expect(find.text('Formulario'), findsOneWidget);
    });

    testWidgets('cancelar mantiene la pantalla abierta', (tester) async {
      await pushProtegida(tester, hayCambios: () => true);

      await volverAtras(tester);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(find.text('Formulario'), findsOneWidget);
      expect(find.text('pantalla anterior'), findsNothing);
    });

    testWidgets('confirmar descarta y sale', (tester) async {
      await pushProtegida(tester, hayCambios: () => true);

      await volverAtras(tester);
      await tester.tap(find.text('Salir'));
      await tester.pumpAndSettle();

      expect(find.text('pantalla anterior'), findsOneWidget);
    });

    testWidgets('la flecha del AppBar también pasa por el guard', (
      tester,
    ) async {
      await pushProtegida(tester, hayCambios: () => true);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.text('Tenés cambios sin guardar'), findsOneWidget);
    });

    testWidgets('el pop programático de guardar no pregunta', (tester) async {
      // Las pantallas hacen `Navigator.pop()` después de guardar. `pop` no
      // consulta al PopScope (a diferencia de `maybePop`), así que el guard no
      // se interpone aunque haya cambios.
      late BuildContext contextoFormulario;
      final navKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navKey,
          theme: AppTheme().light,
          home: const Scaffold(body: Center(child: Text('pantalla anterior'))),
        ),
      );
      navKey.currentState!.push(
        MaterialPageRoute(
          builder: (context) {
            contextoFormulario = context;
            return UnsavedChangesGuard(
              hayCambios: () => true,
              child: const Scaffold(body: Text('Formulario')),
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      Navigator.of(contextoFormulario).pop();
      await tester.pumpAndSettle();

      expect(find.text('Tenés cambios sin guardar'), findsNothing);
      expect(find.text('pantalla anterior'), findsOneWidget);
    });

    testWidgets('el estado se consulta al salir, no al construir', (
      tester,
    ) async {
      // El predicado es un callback justamente para no tener que reconstruir
      // la pantalla en cada tecla: tiene que leer el valor del momento.
      var sucio = false;
      await pushProtegida(tester, hayCambios: () => sucio);

      sucio = true;
      await volverAtras(tester);

      expect(find.text('Tenés cambios sin guardar'), findsOneWidget);
    });
  });
}
