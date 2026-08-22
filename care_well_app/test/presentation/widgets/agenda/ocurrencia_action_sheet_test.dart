import 'dart:async';

import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ─── Fixtures ─────────────────────────────────────────────────────────────────

final _tipo = TipoEvento(id: 1, descripcion: 'Cita Médica');

/// Ocurrencia relativa al reloj: lo que decide qué acciones quedan vivas es si
/// ya empezó, así que la fecha se ancla a "ahora" y no a un día fijo.
OcurrenciaEventoAgenda _ocurrencia({
  required bool esRecurrente,
  bool pasada = false,
}) {
  final ahora = DateTime.now();
  final inicio = pasada
      ? ahora.subtract(const Duration(days: 2))
      : ahora.add(const Duration(days: 2));
  return OcurrenciaEventoAgenda(
    id: 7,
    eventoAgendaId: 7,
    personaId: 12,
    titulo: 'Control cardiológico',
    tipo: _tipo,
    fechaHoraInicio: inicio,
    fechaHoraFin: inicio.add(const Duration(hours: 1)),
    esRecurrente: esRecurrente,
    generarEventoSalud: false,
  );
}

// ─── Helper ───────────────────────────────────────────────────────────────────

/// Abre la hoja y devuelve la acción elegida (o `null` si se descartó).
///
/// La acción llega por el `Future` de `show`, así que el test toca el ítem y
/// después espera a que la hoja termine de cerrarse.
Future<OcurrenciaAccion?> _abrirYTocar(
  WidgetTester tester, {
  required bool esRecurrente,
  required String label,
  bool pasada = false,
}) async {
  OcurrenciaAccion? elegida;

  await _abrir(
    tester,
    esRecurrente: esRecurrente,
    pasada: pasada,
    alCerrar: (v) => elegida = v,
  );

  await tester.tap(find.text(label));
  await tester.pumpAndSettle();

  return elegida;
}

/// Monta una pantalla mínima y abre la hoja sobre la ocurrencia pedida.
///
/// El resultado se entrega por [alCerrar] en lugar de devolver el `Future` de
/// `show`: sobre una ocurrencia pasada la hoja no se cierra sola y esperarlo
/// colgaría el test.
Future<void> _abrir(
  WidgetTester tester, {
  required bool esRecurrente,
  bool pasada = false,
  ValueChanged<OcurrenciaAccion?>? alCerrar,
}) async {
  late BuildContext ctx;

  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) {
          ctx = context;
          return const Scaffold(body: SizedBox.shrink());
        },
      ),
    ),
  );

  unawaited(
    OcurrenciaActionSheet.show(
      ctx,
      ocurrencia: _ocurrencia(esRecurrente: esRecurrente, pasada: pasada),
    ).then((v) => alCerrar?.call(v)),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('OcurrenciaActionSheet', () {
    testWidgets('en un evento único ofrece editar y eliminar el evento', (
      tester,
    ) async {
      final elegida = await _abrirYTocar(
        tester,
        esRecurrente: false,
        label: 'Eliminar evento',
      );

      expect(elegida, OcurrenciaAccion.eliminarEvento);
    });

    testWidgets('en un evento único la acción de editar está disponible', (
      tester,
    ) async {
      final elegida = await _abrirYTocar(
        tester,
        esRecurrente: false,
        label: 'Editar evento',
      );

      expect(elegida, OcurrenciaAccion.editar);
    });

    // El backend no borra series ya iniciadas: la baja recorta de la ocurrencia
    // elegida en adelante, y el rótulo tiene que decirlo.
    testWidgets(
      'en una serie la acción destructiva corta desde la ocurrencia',
      (tester) async {
        final elegida = await _abrirYTocar(
          tester,
          esRecurrente: true,
          label: 'Eliminar esta y las siguientes',
        );

        expect(elegida, OcurrenciaAccion.eliminarSerieDesde);
        expect(find.text('Eliminar toda la serie'), findsNothing);
      },
    );

    testWidgets('en una serie se puede cancelar solo una ocurrencia', (
      tester,
    ) async {
      final elegida = await _abrirYTocar(
        tester,
        esRecurrente: true,
        label: 'Cancelar solo esta ocurrencia',
      );

      expect(elegida, OcurrenciaAccion.cancelarOcurrencia);
      // Editar no se ofrece en series: cambiaría toda la recurrencia.
      expect(find.text('Editar evento'), findsNothing);
    });

    // El backend rechaza modificar, eliminar y cancelar sobre lo ya ocurrido:
    // ofrecer esas acciones era garantizar un 400.
    group('ocurrencia que ya empezó', () {
      testWidgets('explica por qué no hay nada para hacer', (tester) async {
        await _abrir(tester, esRecurrente: true, pasada: true);

        expect(
          find.text(
            'Este evento ya ocurrió: no se puede modificar ni eliminar.',
          ),
          findsOneWidget,
        );
      });

      for (final (nombre, esRecurrente, labels) in [
        ('un evento único', false, ['Editar evento', 'Eliminar evento']),
        (
          'una serie',
          true,
          ['Cancelar solo esta ocurrencia', 'Eliminar esta y las siguientes'],
        ),
      ]) {
        testWidgets('en $nombre las acciones quedan inertes', (tester) async {
          await _abrir(tester, esRecurrente: esRecurrente, pasada: true);

          for (final label in labels) {
            final tile = tester.widget<ListTile>(
              find.ancestor(
                of: find.text(label),
                matching: find.byType(ListTile),
              ),
            );
            expect(
              tile.enabled,
              isFalse,
              reason: '"$label" debería estar deshabilitada',
            );
            expect(tile.onTap, isNull);
          }
        });
      }

      testWidgets('tocar la acción destructiva no cierra la hoja', (
        tester,
      ) async {
        OcurrenciaAccion? elegida;
        var cerro = false;
        await _abrir(
          tester,
          esRecurrente: true,
          pasada: true,
          alCerrar: (v) {
            cerro = true;
            elegida = v;
          },
        );

        await tester.tap(find.text('Eliminar esta y las siguientes'));
        await tester.pumpAndSettle();

        expect(cerro, isFalse);
        expect(elegida, isNull);
        expect(find.text('Eliminar esta y las siguientes'), findsOneWidget);
      });
    });
  });
}
