import 'package:care_well_app/config/routers/app_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Pantalla mínima con AppBar, para observar la flecha de retroceso.
Widget _pantalla(String titulo, {VoidCallback? onVolver}) => Scaffold(
  appBar: AppBar(title: Text(titulo)),
  body: Center(
    child: TextButton(onPressed: onVolver, child: const Text('volver')),
  ),
);

/// Router de prueba, para no depender del router real de la app.
///
/// `/suelta` es una ruta de primer nivel: al entrar directamente en ella no
/// queda nada debajo que desapilar (es el caso que ejercita el fallback).
GoRouter _router({required String fallback}) => GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(path: '/home', builder: (_, _) => _pantalla('home')),
    GoRoute(path: '/lista', builder: (_, _) => _pantalla('lista')),
    GoRoute(
      path: '/suelta',
      builder: (context, _) =>
          _pantalla('suelta', onVolver: () => context.volverA(fallback)),
    ),
  ],
);

void main() {
  group('AppNavigation.volverA', () {
    testWidgets('desapila la pantalla actual cuando hay historia', (
      tester,
    ) async {
      final router = _router(fallback: '/lista');
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      router.push('/lista');
      await tester.pumpAndSettle();
      router.push('/suelta');
      await tester.pumpAndSettle();

      await tester.tap(find.text('volver'));
      await tester.pumpAndSettle();

      // Vuelve a la lista sin perder Home: el back sigue disponible y,
      // desapilando de nuevo, se llega al inicio.
      expect(find.text('lista'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('home'), findsOneWidget);
    });

    testWidgets('sin historia reconstruye un stack navegable hasta Home', (
      tester,
    ) async {
      final router = _router(fallback: '/lista');
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      // Entrada directa (deep link / toque de notificación): no hay nada que
      // desapilar.
      router.go('/suelta');
      await tester.pumpAndSettle();

      await tester.tap(find.text('volver'));
      await tester.pumpAndSettle();

      expect(find.text('lista'), findsOneWidget);
      // El fallback no puede dejar una página huérfana: sin flecha de
      // retroceso, el gesto de back cerraría la aplicación.
      expect(find.byType(BackButton), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('home'), findsOneWidget);
    });
  });
}
