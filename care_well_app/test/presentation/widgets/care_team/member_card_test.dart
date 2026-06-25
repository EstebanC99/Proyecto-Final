import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/widgets/care_team/member_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../_fakes/test_fixtures.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

final _personaCuidada = Persona(id: 1, nombre: 'Alicia', apellido: 'Rodríguez');

final _personaCarlos = Persona(
  id: 3,
  nombre: 'Carlos',
  apellido: 'Pérez',
  email: 'carlos@test.com',
);

AsignacionCuidado _asignacionResponsable() => AsignacionCuidado(
  id: 401,
  personaCuidada: _personaCuidada,
  personaColaborador: _personaCarlos,
  rol: rolCuidadoResponsable,
  estado: estadoAsignacionActiva,
  fechaAlta: DateTime(2024, 1, 10),
);

AsignacionCuidado _asignacionCuidador() => AsignacionCuidado(
  id: 402,
  personaCuidada: _personaCuidada,
  personaColaborador: _personaCarlos,
  rol: rolCuidadoCuidador,
  estado: estadoAsignacionActiva,
  fechaAlta: DateTime(2024, 3, 5),
);

void main() {
  group('MemberCard', () {
    testWidgets('renderiza sin errores (smoke)', (tester) async {
      await tester.pumpWidget(
        _wrap(
          MemberCard(
            asignacion: _asignacionResponsable(),
            isCurrentUser: false,
            onTap: () {},
          ),
        ),
      );

      expect(find.byType(MemberCard), findsOneWidget);
    });

    testWidgets('muestra el nombre del colaborador', (tester) async {
      await tester.pumpWidget(
        _wrap(
          MemberCard(
            asignacion: _asignacionResponsable(),
            isCurrentUser: false,
            onTap: () {},
          ),
        ),
      );

      expect(find.text('Carlos Pérez'), findsOneWidget);
    });

    testWidgets('muestra el email del colaborador cuando está disponible', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          MemberCard(
            asignacion: _asignacionResponsable(),
            isCurrentUser: false,
            onTap: () {},
          ),
        ),
      );

      expect(find.text('carlos@test.com'), findsOneWidget);
    });

    testWidgets('muestra badge Responsable para rol responsable', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          MemberCard(
            asignacion: _asignacionResponsable(),
            isCurrentUser: false,
            onTap: () {},
          ),
        ),
      );

      expect(find.text('Responsable'), findsOneWidget);
    });

    testWidgets('muestra badge Cuidador para rol cuidador', (tester) async {
      await tester.pumpWidget(
        _wrap(
          MemberCard(
            asignacion: _asignacionCuidador(),
            isCurrentUser: false,
            onTap: () {},
          ),
        ),
      );

      expect(find.text('Cuidador'), findsOneWidget);
    });

    testWidgets('muestra "(Vos)" cuando isCurrentUser es true', (tester) async {
      await tester.pumpWidget(
        _wrap(
          MemberCard(
            asignacion: _asignacionResponsable(),
            isCurrentUser: true,
            onTap: () {},
          ),
        ),
      );

      expect(find.text('(Vos)'), findsOneWidget);
    });

    testWidgets('no muestra "(Vos)" cuando isCurrentUser es false', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          MemberCard(
            asignacion: _asignacionResponsable(),
            isCurrentUser: false,
            onTap: () {},
          ),
        ),
      );

      expect(find.text('(Vos)'), findsNothing);
    });

    testWidgets('muestra chevron por defecto', (tester) async {
      await tester.pumpWidget(
        _wrap(
          MemberCard(
            asignacion: _asignacionResponsable(),
            isCurrentUser: false,
            onTap: () {},
          ),
        ),
      );

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('oculta chevron cuando showChevron es false', (tester) async {
      await tester.pumpWidget(
        _wrap(
          MemberCard(
            asignacion: _asignacionResponsable(),
            isCurrentUser: false,
            onTap: () {},
            showChevron: false,
          ),
        ),
      );

      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });

    testWidgets('dispara onTap al presionar', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        _wrap(
          MemberCard(
            asignacion: _asignacionResponsable(),
            isCurrentUser: false,
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(MemberCard));
      expect(tapped, isTrue);
    });
  });
}
