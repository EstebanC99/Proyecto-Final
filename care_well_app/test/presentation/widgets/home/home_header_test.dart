import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Envuelve [child] con [ProviderScope] y [MaterialApp].
///
/// Sobrescribe [personaImagenProvider] a `null` para que el avatar caiga al
/// fallback de inicial sin golpear el repositorio real.
Widget _wrap(Widget child) => ProviderScope(
  overrides: [personaImagenProvider.overrideWith((ref, id) async => null)],
  child: MaterialApp(home: Scaffold(body: child)),
);

/// Drena los timers de la animación de entrada (animate_do).
Future<void> _drainAnimations(WidgetTester tester) async {
  await tester.pump(Duration.zero);
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  group('HomeHeader', () {
    testWidgets('renderiza sin errores (smoke)', (tester) async {
      await tester.pumpWidget(_wrap(const HomeHeader(userName: 'María')));
      await _drainAnimations(tester);
      expect(find.byType(HomeHeader), findsOneWidget);
    });

    testWidgets('muestra el wordmark y el saludo', (tester) async {
      await tester.pumpWidget(_wrap(const HomeHeader(userName: 'María')));
      await _drainAnimations(tester);

      expect(find.text('Hola, María'), findsOneWidget);
      // El wordmark bicolor se arma con RichText (Care + Well).
      expect(find.byType(RichText), findsWidgets);
    });

    testWidgets('el chip de cuenta dispara onTapProfile', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(HomeHeader(userName: 'María', onTapProfile: () => tapped = true)),
      );
      await _drainAnimations(tester);

      await tester.tap(find.text('Hola, María'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('no muestra campana de notificaciones', (tester) async {
      await tester.pumpWidget(_wrap(const HomeHeader(userName: 'María')));
      await _drainAnimations(tester);

      expect(find.byIcon(Icons.notifications), findsNothing);
      expect(find.byIcon(Icons.notifications_none), findsNothing);
      expect(find.byIcon(Icons.notifications_outlined), findsNothing);
    });

    testWidgets('con nombre largo no desborda', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const HomeHeader(
            userName: 'Bartolomé Wenceslao de la Santísima Trinidad',
          ),
        ),
      );
      await _drainAnimations(tester);

      expect(tester.takeException(), isNull);
    });
  });
}
