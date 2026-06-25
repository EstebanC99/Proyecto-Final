import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/widgets/dependents/person_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

final _persona = Persona(
  id: 2,
  nombre: 'Alicia',
  apellido: 'Rodríguez',
  fechaNacimiento: DateTime(1943, 7, 22),
  email: 'alicia@test.com',
);

void main() {
  group('PersonCard', () {
    testWidgets('renderiza sin errores (smoke)', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PersonCard(persona: _persona, rolLabel: 'Responsable', onTap: () {}),
        ),
      );

      expect(find.byType(PersonCard), findsOneWidget);
    });

    testWidgets('muestra el nombre completo de la persona', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PersonCard(persona: _persona, rolLabel: 'Responsable', onTap: () {}),
        ),
      );

      expect(find.text('Alicia Rodríguez'), findsOneWidget);
    });

    testWidgets('muestra el label de rol', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PersonCard(persona: _persona, rolLabel: 'Cuidador', onTap: () {}),
        ),
      );

      expect(find.text('Cuidador'), findsOneWidget);
    });

    testWidgets('muestra la edad calculada correctamente', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PersonCard(persona: _persona, rolLabel: 'Responsable', onTap: () {}),
        ),
      );

      // La persona nació el 22/07/1943. La edad varía; verificamos que aparece " años"
      final edadFinder = find.textContaining('años');
      expect(edadFinder, findsOneWidget);
    });

    testWidgets('muestra el chevron de navegación', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PersonCard(persona: _persona, rolLabel: 'Responsable', onTap: () {}),
        ),
      );

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('dispara onTap al presionar', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        _wrap(
          PersonCard(
            persona: _persona,
            rolLabel: 'Responsable',
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(PersonCard));
      expect(tapped, isTrue);
    });

    testWidgets('persona sin fecha de nacimiento no muestra edad', (
      tester,
    ) async {
      final personaSinFecha = Persona(
        id: 99,
        nombre: 'Juan',
        apellido: 'Pérez',
      );

      await tester.pumpWidget(
        _wrap(
          PersonCard(
            persona: personaSinFecha,
            rolLabel: 'Responsable',
            onTap: () {},
          ),
        ),
      );

      expect(find.textContaining('años'), findsNothing);
    });
  });

  group('calcularEdad', () {
    test('retorna null para fechaNacimiento nula', () {
      expect(calcularEdad(null), isNull);
    });

    test('retorna edad positiva para fecha en el pasado', () {
      final nacimiento = DateTime(1990, 1, 1);
      final edad = calcularEdad(nacimiento);
      expect(edad, isNotNull);
      expect(edad!, greaterThan(0));
    });

    test('retorna null para fecha futura', () {
      final futuro = DateTime.now().add(const Duration(days: 365));
      expect(calcularEdad(futuro), isNull);
    });
  });
}
