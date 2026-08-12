import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/screens/screens.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../_fakes/test_fixtures.dart';

final _personaMaria = Persona(
  id: 1,
  nombre: 'María',
  apellido: 'García',
  documento: '28000001',
  fechaNacimiento: DateTime(1990, 1, 1),
);

final _personaAlicia = Persona(
  id: 2,
  nombre: 'Alicia',
  apellido: 'Rodríguez',
  documento: '5234100',
  fechaNacimiento: DateTime(1943, 7, 22),
);

final _habitoPendiente = HabitoVida(
  id: 901,
  persona: refPersonaAlicia,
  tipo: tipoHabitoActividadFisica,
  descripcion: 'Caminata diaria',
);

final _habitoRealizado = HabitoVida(
  id: 902,
  persona: refPersonaAlicia,
  tipo: tipoHabitoAlimentacion,
  descripcion: 'Desayuno completo',
  realizacion: RealizacionHabitoVida(
    id: 1,
    habitoId: 902,
    fechaHora: DateTime.now(),
  ),
);

final _ficha = FichaSalud(
  id: 1,
  persona: _personaAlicia,
  factorSanguineo: '0+',
  alergias: [
    FichaSaludAlergia(id: 1, nombre: 'Polen', reaccion: 'Estornudos'),
    FichaSaludAlergia(id: 2, nombre: 'Penicilina', reaccion: 'Urticaria'),
  ],
  antecedentes: [
    FichaSaludAntecedente(
      id: 1,
      nombre: 'Diabetes',
      descripcion: 'Tipo 2',
      vinculoFamiliar: 'Madre',
    ),
  ],
);

PersonaEstadoAnimo _animoHoy() => PersonaEstadoAnimo(
  id: 1,
  persona: _personaAlicia,
  fecha: DateTime.now(),
  estado: estadoAnimoBien,
);

EventoSalud _eventoHace3Dias() => EventoSalud(
  id: 1,
  persona: refPersonaAlicia,
  tipo: TipoEventoSalud(id: 1, descripcion: 'Dolor de garganta'),
  fechaHora: DateTime.now().subtract(const Duration(days: 3)),
  descripcion: 'Molestia al tragar',
);

Widget _wrap({
  Persona? persona,
  bool puedeVerFicha = true,
  FichaSalud? ficha,
  List<HabitoVida>? habitos,
  PersonaEstadoAnimo? animoHoy,
  EventoSalud? ultimoEvento,
}) {
  final personaEfectiva = persona ?? _personaAlicia;
  return ProviderScope(
    overrides: [
      // ContextSelector necesita estos providers.
      personaVisualizacionSeleccionadaProvider.overrideWith(
        (ref) async => personaEfectiva,
      ),
      personasSeleccionablesProvider.overrideWith(
        (ref) async => [
          PersonaContextOption(
            persona: _personaMaria,
            rol: PersonaContextRol.propio,
          ),
          PersonaContextOption(
            persona: _personaAlicia,
            rol: PersonaContextRol.responsable,
          ),
        ],
      ),
      puedeVerSaludProvider.overrideWith((ref) async => puedeVerFicha),
      fichaSaludProvider.overrideWith((ref) async => ficha),
      habitosProvider.overrideWith((ref) async => habitos ?? []),
      animoHoyProvider.overrideWith((ref) async => animoHoy),
      ultimoEventoSaludProvider.overrideWith((ref) async => ultimoEvento),
    ],
    child: const MaterialApp(home: HealthScreen()),
  );
}

void main() {
  group('HealthScreen', () {
    testWidgets('smoke: renderiza sin errores', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();
      expect(find.byType(HealthScreen), findsOneWidget);
    });

    testWidgets('muestra ContextSelector con nombre de persona', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();
      expect(find.byType(ContextSelector), findsOneWidget);
      expect(find.textContaining('Alicia Rodríguez'), findsOneWidget);
    });

    testWidgets('el ContextSelector vive en el AppBar y usa su variante', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      // El selector es el título de la pantalla: rótulo de sección en versales
      // y badge de rol abreviado.
      expect(find.byType(ContextAppBar), findsOneWidget);
      expect(find.byType(ContextCompactBanner), findsOneWidget);
      expect(find.text('SALUD'), findsOneWidget);
      expect(find.text('RESP.'), findsOneWidget);
      // Con dos personas seleccionables aparece el chevron, pero en el AppBar
      // no hay mini-avatares: solo el avatar de la persona de contexto.
      expect(find.byIcon(Icons.expand_more), findsOneWidget);
      expect(find.byType(PersonaAvatar), findsOneWidget);
    });

    testWidgets('muestra la ficha destacada y las tarjetas de seguimiento', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.byType(HealthRecordHighlightCard), findsOneWidget);
      expect(find.byType(HealthMetricCard), findsNWidgets(3));
      expect(find.text('Ficha de salud'), findsOneWidget);
      expect(find.text('Hábitos de vida'), findsOneWidget);
      expect(find.text('Estado de ánimo'), findsOneWidget);
      expect(find.text('Eventos de salud'), findsOneWidget);
      expect(find.text('SEGUIMIENTO'), findsOneWidget);
    });

    testWidgets('muestra las métricas del día cuando hay datos', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          ficha: _ficha,
          habitos: [_habitoPendiente, _habitoRealizado],
          animoHoy: _animoHoy(),
          ultimoEvento: _eventoHace3Dias(),
        ),
      );
      await tester.pumpAndSettle();

      // Hábitos: 1 de 2 completados.
      expect(find.textContaining('1 de 2'), findsOneWidget);
      // Ánimo de hoy.
      expect(find.textContaining('Bien'), findsOneWidget);
      // Último evento con su tipo.
      expect(find.textContaining('hace 3 días'), findsOneWidget);
      expect(find.textContaining('Dolor de garganta'), findsOneWidget);
      // Chips de la ficha.
      expect(find.textContaining('0+'), findsOneWidget);
      expect(find.textContaining('2 alergias'), findsOneWidget);
      expect(find.textContaining('1 antecedente'), findsOneWidget);
    });

    testWidgets('sin datos cada tarjeta muestra su copy de vacío', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.textContaining('Sin hábitos cargados'), findsOneWidget);
      expect(find.textContaining('Sin registro hoy'), findsOneWidget);
      expect(find.textContaining('Sin eventos registrados'), findsOneWidget);
      expect(find.textContaining('Sin grupo cargado'), findsOneWidget);
    });

    testWidgets('sin permiso la ficha se bloquea y no muestra chips', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(puedeVerFicha: false, ficha: _ficha));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget); // solo eventos
      expect(find.textContaining('alergias'), findsNothing);
    });

    testWidgets('sin persona muestra mensaje de estado vacío', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            personaVisualizacionSeleccionadaProvider.overrideWith(
              (ref) async => null,
            ),
            personasSeleccionablesProvider.overrideWith((ref) async => []),
          ],
          child: const MaterialApp(home: HealthScreen()),
        ),
      );
      await tester.pump();
      expect(find.textContaining('persona a cargo'), findsOneWidget);
    });
  });
}
