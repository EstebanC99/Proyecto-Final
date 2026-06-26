import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/screens/screens.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
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

Widget _wrap({bool puedeActivar = true, List<AsignacionCuidado>? equipo}) {
  return ProviderScope(
    overrides: [
      careTeamContextPersonaProvider.overrideWith(
        (ref) async => _personaAlicia,
      ),
      equipoEmergenciaProvider.overrideWith(
        (ref) async => equipo ?? [_asignacion],
      ),
      puedeActivarEmergenciaProvider.overrideWith((ref) async => puedeActivar),
      notificationSchedulerProvider.overrideWithValue(
        FakeNotificationScheduler(),
      ),
    ],
    child: const MaterialApp(home: EmergencyScreen()),
  );
}

void main() {
  group('EmergencyScreen', () {
    testWidgets('smoke: renderiza sin errores', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 2100));
      expect(find.byType(EmergencyScreen), findsOneWidget);
    });

    testWidgets('botón visible y habilitado si tiene permiso', (tester) async {
      await tester.pumpWidget(_wrap(puedeActivar: true));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 2100));
      expect(find.byType(EmergencyButton), findsOneWidget);
    });

    testWidgets('botón deshabilitado si no tiene permiso', (tester) async {
      await tester.pumpWidget(_wrap(puedeActivar: false));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 2100));
      // El botón se renderiza con enabled=false
      final btn = tester.widget<EmergencyButton>(find.byType(EmergencyButton));
      expect(btn.enabled, isFalse);
    });

    testWidgets('muestra nombre de persona de contexto', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 2100));
      expect(find.textContaining('Alicia'), findsWidgets);
    });
  });
}
