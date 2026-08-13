import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/screens/screens.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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

/// Resumen con datos en las cuatro tarjetas.
const _resumenCompleto = ResumenSalud(
  grupoSanguineo: '0+',
  cantidadAlergias: 2,
  cantidadAntecedentes: 1,
  cantidadEnfermedades: 0,
  cantidadHabitosCompletados: 1,
  cantidadHabitos: 2,
  estadoAnimoId: EstadosAnimoConst.bien,
  ultimoEventoSalud: 'Dolor de garganta',
  diasDesdeUltimoEvento: 3,
);

/// Persona sin ficha, sin hábitos, sin ánimo de hoy y sin eventos.
const _resumenVacio = ResumenSalud(
  cantidadHabitosCompletados: 0,
  cantidadHabitos: 0,
);

Widget _wrap({
  Persona? persona,
  bool puedeVerFicha = true,
  ResumenSalud? resumen = _resumenVacio,
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
      resumenSaludProvider.overrideWith((ref) async => resumen),
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
      await tester.pumpWidget(_wrap(resumen: _resumenCompleto));
      await tester.pumpAndSettle();

      // Hábitos: 1 de 2 completados.
      expect(find.textContaining('1 de 2'), findsOneWidget);
      // Ánimo de hoy, resuelto por id contra el catálogo local.
      expect(find.textContaining('Bien'), findsOneWidget);
      // Último evento: días relativos + tipo.
      expect(find.textContaining('hace 3 días'), findsOneWidget);
      expect(find.textContaining('Dolor de garganta'), findsOneWidget);
      // Chips de la ficha (las enfermedades en cero no se muestran).
      expect(find.textContaining('0+'), findsOneWidget);
      expect(find.textContaining('2 alergias'), findsOneWidget);
      expect(find.textContaining('1 antecedente'), findsOneWidget);
      expect(find.textContaining('enfermedad'), findsNothing);
    });

    testWidgets('sin datos cada tarjeta muestra su copy de vacío', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.textContaining('Sin hábitos cargados'), findsOneWidget);
      expect(find.textContaining('Sin registro hoy'), findsOneWidget);
      expect(find.textContaining('Sin eventos registrados'), findsOneWidget);
      // Sin ficha cargada no se dibujan chips: ni siquiera el de grupo.
      expect(find.textContaining('Sin grupo cargado'), findsNothing);
    });

    // El permiso protege el detalle clínico, no el resumen agregado.
    testWidgets('sin permiso muestra los chips igual, pero con candado', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(puedeVerFicha: false, resumen: _resumenCompleto),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('2 alergias'), findsOneWidget);
      expect(find.textContaining('0+'), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      // El chevron de la ficha no está; el único que queda es el de eventos.
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    // La degradación mientras el resumen carga (tarjeta sin métrica) se cubre
    // en `health_metric_card_test.dart`: a nivel de pantalla haría falta un
    // provider que nunca resuelve, y eso choca con la descarga de la imagen de
    // PersonaAvatar, que deja timers pendientes.

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
