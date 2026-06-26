import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../_fakes/fake_notification_scheduler.dart';
import '../../../_fakes/test_fixtures.dart';

final _personaAlicia = Persona(
  id: 2,
  nombre: 'Alicia',
  apellido: 'Rodríguez',
  documento: '5234100',
  fechaNacimiento: DateTime(1943, 7, 22),
);

final _personaMaria = Persona(
  id: 1,
  nombre: 'María',
  apellido: 'García',
  documento: '28000001',
  fechaNacimiento: DateTime(1990, 1, 1),
);

final _asignacion = AsignacionCuidado(
  id: 401,
  personaCuidada: _personaAlicia,
  colaborador: _personaMaria,
  rol: rolCuidadoResponsable,
  estado: estadoAsignacionActiva,
  fechaAlta: DateTime(2024, 1, 8),
);

Widget _wrap({List<AsignacionCuidado>? equipo}) {
  return ProviderScope(
    overrides: [
      equipoEmergenciaProvider.overrideWith(
        (ref) async => equipo ?? [_asignacion],
      ),
      notificationSchedulerProvider.overrideWithValue(
        FakeNotificationScheduler(),
      ),
    ],
    child: const MaterialApp(home: EmergencySentScreen()),
  );
}

void main() {
  group('EmergencySentScreen', () {
    testWidgets('smoke: renderiza sin errores', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      // ZoomIn de animate_do tiene timer de animación; drenamos para evitar timers pendientes.
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(EmergencySentScreen), findsOneWidget);
    });

    testWidgets('muestra título "Alerta enviada"', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Alerta enviada'), findsOneWidget);
    });

    testWidgets('botón volver al inicio visible', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Volver al inicio'), findsOneWidget);
    });
  });
}
