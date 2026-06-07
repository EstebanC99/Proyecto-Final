import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('EmptyStateTile', () {
    testWidgets('renderiza sin errores (smoke)', (tester) async {
      await tester.pumpWidget(
        _wrap(
          EmptyStateTile(
            accentColor: Colors.orange,
            onTap: () {},
            onTapAdd: () {},
          ),
        ),
      );
      expect(find.byType(EmptyStateTile), findsOneWidget);
    });

    testWidgets('muestra el texto de estado vacío', (tester) async {
      await tester.pumpWidget(
        _wrap(
          EmptyStateTile(
            accentColor: Colors.orange,
            onTap: () {},
            onTapAdd: () {},
          ),
        ),
      );
      expect(find.textContaining('no tenés'), findsOneWidget);
    });

    testWidgets('muestra el ícono elderly', (tester) async {
      await tester.pumpWidget(
        _wrap(
          EmptyStateTile(
            accentColor: Colors.orange,
            onTap: () {},
            onTapAdd: () {},
          ),
        ),
      );
      expect(find.byIcon(Icons.elderly), findsOneWidget);
    });

    testWidgets('muestra el botón +', (tester) async {
      await tester.pumpWidget(
        _wrap(
          EmptyStateTile(
            accentColor: Colors.orange,
            onTap: () {},
            onTapAdd: () {},
          ),
        ),
      );
      expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
    });

    testWidgets('onTap se dispara al presionar el cuerpo', (tester) async {
      var bodyTapped = false;
      await tester.pumpWidget(
        _wrap(
          EmptyStateTile(
            accentColor: Colors.orange,
            onTap: () => bodyTapped = true,
            onTapAdd: () {},
          ),
        ),
      );
      // Toca el ícono elderly (parte del cuerpo)
      await tester.tap(find.byIcon(Icons.elderly));
      expect(bodyTapped, isTrue);
    });

    testWidgets('onTapAdd se dispara al presionar el botón +', (tester) async {
      var addTapped = false;
      await tester.pumpWidget(
        _wrap(
          EmptyStateTile(
            accentColor: Colors.orange,
            onTap: () {},
            onTapAdd: () => addTapped = true,
          ),
        ),
      );
      await tester.tap(find.byIcon(Icons.add_circle_outline));
      expect(addTapped, isTrue);
    });
  });
}
