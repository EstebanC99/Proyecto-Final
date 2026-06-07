import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

/// Avanza el reloj lo suficiente para que la animación FadeInUp (400ms) termine
/// y drena todos los timers de animate_do (configAnimation + buildAnimation).
Future<void> _drainAnimations(WidgetTester tester) async {
  await tester.pump(Duration.zero); // drena el Future.delayed(zero) inicial
  await tester.pump(const Duration(milliseconds: 500)); // completa la animación
}

void main() {
  group('NavTile', () {
    testWidgets('renderiza sin errores (smoke)', (tester) async {
      await tester.pumpWidget(
        _wrap(
          NavTile(
            icon: Icons.calendar_month,
            label: 'Mi calendario',
            accentColor: Colors.blue,
            onTap: () {},
          ),
        ),
      );
      await _drainAnimations(tester);
      expect(find.byType(NavTile), findsOneWidget);
    });

    testWidgets('muestra el label correctamente', (tester) async {
      await tester.pumpWidget(
        _wrap(
          NavTile(
            icon: Icons.calendar_month,
            label: 'Mi calendario',
            accentColor: Colors.blue,
            onTap: () {},
          ),
        ),
      );
      await _drainAnimations(tester);
      expect(find.text('Mi calendario'), findsOneWidget);
    });

    testWidgets('muestra el ícono correctamente', (tester) async {
      await tester.pumpWidget(
        _wrap(
          NavTile(
            icon: Icons.calendar_month,
            label: 'Mi calendario',
            accentColor: Colors.blue,
            onTap: () {},
          ),
        ),
      );
      await _drainAnimations(tester);
      expect(find.byIcon(Icons.calendar_month), findsOneWidget);
    });

    testWidgets('dispara onTap al presionar', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          NavTile(
            icon: Icons.calendar_month,
            label: 'Mi calendario',
            accentColor: Colors.blue,
            onTap: () => tapped = true,
          ),
        ),
      );
      // Drena el timer inicial de configAnimation.
      await tester.pump(Duration.zero);
      // NavTile ocupa todo el Scaffold.body (800x600 en test). Con FadeInUp(from=100),
      // el widget está desplazado 100px hacia abajo. El tap funciona porque el
      // GestureDetector es lo suficientemente grande para que el tap en el centro
      // del RenderTransform (400, 300) caiga dentro del área visual (y=[100, 700]).
      await tester.tap(find.byType(NavTile), warnIfMissed: false);
      // Drena timer del setState y completa la animación.
      await tester.pump(Duration.zero);
      await tester.pump(const Duration(milliseconds: 500));
      expect(tapped, isTrue);
    });

    testWidgets('renderiza correctamente sin badge (badge == null)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          NavTile(
            icon: Icons.favorite,
            label: 'Salud',
            accentColor: Colors.pink,
            onTap: () {},
            badge: null,
          ),
        ),
      );
      await _drainAnimations(tester);
      expect(find.byType(NavTile), findsOneWidget);
      // Sin badge no debe renderizarse ningún widget Positioned.
      expect(find.byType(Positioned), findsNothing);
    });

    testWidgets('renderiza badge cuando se provee', (tester) async {
      const badgeKey = Key('test-badge');
      await tester.pumpWidget(
        _wrap(
          NavTile(
            icon: Icons.favorite,
            label: 'Salud',
            accentColor: Colors.pink,
            onTap: () {},
            badge: SizedBox(key: badgeKey, width: 24, height: 24),
          ),
        ),
      );
      await _drainAnimations(tester);
      expect(find.byKey(badgeKey), findsOneWidget);
    });
  });
}
