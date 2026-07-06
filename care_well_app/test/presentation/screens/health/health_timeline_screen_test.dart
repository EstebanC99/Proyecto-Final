import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/screens/screens.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

final _personaAlicia = Persona(
  id: 2,
  nombre: 'Alicia',
  apellido: 'Rodríguez',
  documento: '5234100',
  fechaNacimiento: DateTime(1943, 7, 22),
);

final _hoy = DateTime.now();

final _eventos = <EventoBase>[
  EventoBase(
    id: 1,
    descripcion: 'Caminata matutina',
    categoriaEvento: 'Hábito',
    fechaHora: DateTime(_hoy.year, _hoy.month, _hoy.day, 8),
  ),
  EventoBase(
    id: 2,
    descripcion: 'Control cardiológico',
    categoriaEvento: 'Evento',
    fechaHora: DateTime(_hoy.year, _hoy.month, _hoy.day, 11),
  ),
  EventoBase(
    id: 3,
    descripcion: 'Ánimo tranquilo',
    categoriaEvento: 'Ánimo',
    fechaHora: DateTime(_hoy.year, _hoy.month, _hoy.day, 20),
  ),
];

Widget _wrap({List<EventoBase>? eventos, Persona? persona}) {
  return ProviderScope(
    overrides: [
      lineaTiempoDelMesProvider.overrideWith((ref) async => eventos ?? _eventos),
      healthPersonaContextProvider.overrideWith(
        (ref) async => persona ?? _personaAlicia,
      ),
    ],
    child: const MaterialApp(home: HealthTimelineScreen()),
  );
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  group('HealthTimelineScreen', () {
    testWidgets('smoke: renderiza sin errores', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(HealthTimelineScreen), findsOneWidget);
    });

    testWidgets('muestra la línea de tiempo con las 3 categorías', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(HealthTimelineView), findsOneWidget);
      expect(find.byType(HealthTimelineTile), findsNWidgets(3));
    });

    testWidgets('no expone FAB (solo lectura)', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('muestra estado vacío cuando no hay registros', (tester) async {
      await tester.pumpWidget(_wrap(eventos: []));
      await tester.pump();
      expect(find.text('Sin registros en este mes.'), findsOneWidget);
    });
  });
}
