import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('EmergencyTile', () {
    testWidgets('renderiza sin errores (smoke)', (tester) async {
      await tester.pumpWidget(_wrap(EmergencyTile(onTap: () {})));
      await tester.pumpAndSettle();
      expect(find.byType(EmergencyTile), findsOneWidget);
    });

    testWidgets('muestra el texto Emergencia', (tester) async {
      await tester.pumpWidget(_wrap(EmergencyTile(onTap: () {})));
      await tester.pumpAndSettle();
      expect(find.text('Emergencia'), findsOneWidget);
    });

    testWidgets('muestra el ícono de advertencia', (tester) async {
      await tester.pumpWidget(_wrap(EmergencyTile(onTap: () {})));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('dispara onTap al presionar', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(EmergencyTile(onTap: () => tapped = true)));
      // Primer pump: drena el Future.delayed(zero) de configAnimation.
      await tester.pump(Duration.zero);
      // Tap en la posición visual. FadeInUp(from=100) desplaza el widget 100px
      // hacia abajo. Centro de layout: y=36. Centro visual: y=136.
      await tester.tapAt(const Offset(400, 136));
      // Drena el timer de configAnimation creado por el rebuild del setState.
      await tester.pump(Duration.zero);
      // Avanza para completar la animación y drenar todos los timers.
      await tester.pump(const Duration(milliseconds: 500));
      expect(tapped, isTrue);
    });
  });
}
