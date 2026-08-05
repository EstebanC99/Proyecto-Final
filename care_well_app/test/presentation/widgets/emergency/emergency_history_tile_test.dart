import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

final _personaCuidada = Persona(
  id: 2,
  nombre: 'Alicia',
  apellido: 'Rodríguez',
  documento: '5234100',
  fechaNacimiento: DateTime(1943, 7, 22),
);

final _activador = Persona(
  id: 1,
  nombre: 'María',
  apellido: 'García',
  documento: '28000001',
  fechaNacimiento: DateTime(1990, 1, 1),
);

Emergencia _emergencia({String? descripcion}) => Emergencia(
  id: 7,
  persona: _personaCuidada,
  activador: _activador,
  fechaHora: DateTime(2026, 8, 5, 14, 32),
  descripcion: descripcion,
);

Widget _wrap(Emergencia emergencia) => MaterialApp(
  home: Scaffold(body: EmergencyHistoryTile(emergencia: emergencia)),
);

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  group('EmergencyHistoryTile', () {
    testWidgets('muestra la fecha, la hora y el activador', (tester) async {
      await tester.pumpWidget(_wrap(_emergencia()));

      expect(find.textContaining('2026'), findsOneWidget);
      expect(find.textContaining('14:32'), findsOneWidget);
      expect(find.text('Activada por María García'), findsOneWidget);
    });

    testWidgets('muestra la descripción cuando existe', (tester) async {
      await tester.pumpWidget(
        _wrap(_emergencia(descripcion: 'Caída en el baño.')),
      );

      expect(find.text('Caída en el baño.'), findsOneWidget);
    });

    testWidgets('no muestra la línea de descripción cuando es nula', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(_emergencia()));

      // Solo quedan las dos líneas fijas: fecha·hora y activador.
      expect(find.byType(Text), findsNWidgets(2));
    });

    testWidgets('usa el ícono de historial y no el de alerta', (tester) async {
      // El historial es informativo: no compite visualmente con el botón.
      await tester.pumpWidget(_wrap(_emergencia()));

      expect(find.byIcon(Icons.history), findsOneWidget);
      expect(find.byIcon(Icons.notifications_active), findsNothing);
    });
  });
}
