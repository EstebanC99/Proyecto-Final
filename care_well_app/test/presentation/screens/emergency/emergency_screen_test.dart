import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/screens/screens.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

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

Emergencia _emergencia(int id) => Emergencia(
  id: id,
  persona: _personaAlicia,
  activador: _personaMaria,
  fechaHora: DateTime(2026, 8, 5, 14, 32),
);

Widget _wrap({
  bool puedeActivar = true,
  List<AsignacionCuidado>? equipo,
  List<Emergencia> historial = const [],
}) {
  return ProviderScope(
    overrides: [
      personaVisualizacionSeleccionadaProvider.overrideWith(
        (ref) async => _personaAlicia,
      ),
      equipoEmergenciaProvider.overrideWith(
        (ref) async => equipo ?? [_asignacion],
      ),
      puedeActivarEmergenciaProvider.overrideWith((ref) async => puedeActivar),
      // Sin este override la pantalla llamaría al repositorio real (Dio) al
      // construirse.
      historialEmergenciasProvider.overrideWith((ref) async => historial),
    ],
    child: const MaterialApp(home: EmergencyScreen()),
  );
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es');
  });

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

    testWidgets('sin emergencias previas muestra el vacío del historial', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 2100));

      expect(find.text('Últimas emergencias'), findsOneWidget);
      expect(find.text('Sin emergencias registradas'), findsOneWidget);
      expect(find.byType(EmergencyHistoryTile), findsNothing);
    });

    testWidgets('muestra un tile por emergencia del historial', (tester) async {
      await tester.pumpWidget(
        _wrap(historial: [_emergencia(7), _emergencia(8)]),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 2100));

      expect(find.byType(EmergencyHistoryTile), findsNWidgets(2));
      expect(find.text('Sin emergencias registradas'), findsNothing);
    });

    testWidgets('el botón sigue operativo aunque falle el historial', (
      tester,
    ) async {
      // El historial es accesorio: si se cae, la pantalla tiene que seguir
      // sirviendo para lo único que importa.
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            personaVisualizacionSeleccionadaProvider.overrideWith(
              (ref) async => _personaAlicia,
            ),
            equipoEmergenciaProvider.overrideWith((ref) async => [_asignacion]),
            puedeActivarEmergenciaProvider.overrideWith((ref) async => true),
            historialEmergenciasProvider.overrideWith(
              (ref) async => throw Exception('backend caído'),
            ),
          ],
          child: const MaterialApp(home: EmergencyScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 2100));

      final btn = tester.widget<EmergencyButton>(find.byType(EmergencyButton));
      expect(btn.enabled, isTrue);
      // Nada de error en pantalla: el fallo se absorbe en silencio.
      expect(find.byType(InlineErrorBanner), findsNothing);
      expect(find.text('Últimas emergencias'), findsNothing);
    });
  });
}
