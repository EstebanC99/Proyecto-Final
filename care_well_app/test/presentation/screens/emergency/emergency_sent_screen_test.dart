import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../_fakes/fake_notification_scheduler.dart';

final _personaAlicia = Persona(
  id: 'per_002',
  nombre: 'Alicia',
  apellido: 'Rodríguez',
);

final _personaMaria = Persona(
  id: 'per_001',
  nombre: 'María',
  apellido: 'García',
);

final _rolResponsable = Rol(id: 'rol_001', nombre: RolCuidado.responsable);

final _asignacion = AsignacionCuidado(
  id: 'asi_001',
  personaCuidada: _personaAlicia,
  personaColaborador: _personaMaria,
  rol: _rolResponsable,
  estado: EstadoAsignacion.activa,
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
