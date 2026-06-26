import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/widgets/dependents/person_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../_fakes/test_fixtures.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

final _persona = Persona(
  id: 2,
  nombre: 'Alicia',
  apellido: 'Rodríguez',
  documento: '5234100',
  fechaNacimiento: DateTime(1943, 7, 22),
  email: 'alicia@test.com',
);

// Persona auxiliar de id distinto para la asignación alternativa
final _personaJuan = Persona(
  id: 99,
  nombre: 'Juan',
  apellido: 'Pérez',
  documento: '30000099',
  fechaNacimiento: DateTime(1943, 7, 22),
);

AsignacionCuidado _asignacion({
  int id = 401,
  EstadoAsignacionCuidado? estado,
  RolCuidado? rol,
}) => AsignacionCuidado(
  id: id,
  personaCuidada: _persona,
  colaborador: Persona(
    id: 1,
    nombre: 'María',
    apellido: 'García',
    documento: '28000001',
    fechaNacimiento: DateTime(1990, 1, 1),
  ),
  rol: rol ?? rolCuidadoResponsable,
  estado: estado ?? estadoAsignacionActiva,
  fechaAlta: DateTime(2024, 1, 8),
);

AsignacionCuidado _asignacionJuan() => AsignacionCuidado(
  id: 402,
  personaCuidada: _personaJuan,
  colaborador: Persona(
    id: 1,
    nombre: 'María',
    apellido: 'García',
    documento: '28000001',
    fechaNacimiento: DateTime(1990, 1, 1),
  ),
  rol: rolCuidadoResponsable,
  estado: estadoAsignacionActiva,
  fechaAlta: DateTime(2024, 1, 8),
);

void main() {
  group('PersonCard', () {
    testWidgets('renderiza sin errores (smoke)', (tester) async {
      await tester.pumpWidget(
        _wrap(PersonCard(asignacion: _asignacion(), onTap: () {})),
      );

      expect(find.byType(PersonCard), findsOneWidget);
    });

    testWidgets('muestra el nombre completo de la persona', (tester) async {
      await tester.pumpWidget(
        _wrap(PersonCard(asignacion: _asignacion(), onTap: () {})),
      );

      expect(find.text('Alicia Rodríguez'), findsOneWidget);
    });

    testWidgets('muestra el label de rol desde la asignación', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PersonCard(
            asignacion: _asignacion(rol: rolCuidadoCuidador),
            onTap: () {},
          ),
        ),
      );

      expect(find.text('Cuidador'), findsOneWidget);
    });

    testWidgets('muestra la edad calculada correctamente', (tester) async {
      await tester.pumpWidget(
        _wrap(PersonCard(asignacion: _asignacion(), onTap: () {})),
      );

      // La persona nació el 22/07/1943. Verificamos que aparece " años".
      expect(find.textContaining('años'), findsOneWidget);
    });

    testWidgets('muestra el chevron de navegación', (tester) async {
      await tester.pumpWidget(
        _wrap(PersonCard(asignacion: _asignacion(), onTap: () {})),
      );

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('dispara onTap al presionar', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        _wrap(
          PersonCard(asignacion: _asignacion(), onTap: () => tapped = true),
        ),
      );

      await tester.tap(find.byType(PersonCard));
      expect(tapped, isTrue);
    });

    testWidgets('persona con fecha de nacimiento muestra la edad en años', (
      tester,
    ) async {
      // _persona tiene fechaNacimiento: DateTime(1943, 7, 22), siempre mostrará edad.
      await tester.pumpWidget(
        _wrap(PersonCard(asignacion: _asignacionJuan(), onTap: () {})),
      );

      expect(find.textContaining('años'), findsOneWidget);
    });

    testWidgets('asignación pendiente muestra el chip "Pendiente"', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          PersonCard(
            asignacion: _asignacion(estado: estadoAsignacionPendiente),
            onTap: () {},
          ),
        ),
      );

      expect(find.text('Pendiente'), findsOneWidget);
    });

    testWidgets('asignación activa no muestra el chip "Pendiente"', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(PersonCard(asignacion: _asignacion(), onTap: () {})),
      );

      expect(find.text('Pendiente'), findsNothing);
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
