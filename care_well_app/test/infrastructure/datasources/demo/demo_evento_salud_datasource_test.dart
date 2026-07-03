import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/infrastructure/datasources/demo/demo_evento_salud_datasource.dart';
import 'package:care_well_app/infrastructure/datasources/demo/demo_seed.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DemoEventoSaludDatasource', () {
    late DemoEventoSaludDatasource datasource;

    setUp(() => datasource = DemoEventoSaludDatasource());

    // ─── getEventosSaludDelMes ─────────────────────────────────────────────────

    group('getEventosSaludDelMes', () {
      // El seed de Alicia tiene eventos en junio de 2026 (1103, 1104).
      test('retorna eventos de Alicia en el rango del mes', () async {
        final eventos = await datasource.getEventosSaludDelMes(
          personaId: DemoSeed.personaAliciaId,
          desde: DateTime(2026, 6, 1),
          hasta: DateTime(2026, 7, 1),
        );
        expect(eventos, isNotEmpty);
      });

      test('incluye evento de tipo citaMedica en el seed', () async {
        final eventos = await datasource.getEventosSaludDelMes(
          personaId: DemoSeed.personaAliciaId,
          desde: DateTime(2026, 6, 1),
          hasta: DateTime(2026, 7, 1),
        );
        expect(
          eventos.any((e) => e.tipo.id == TiposEventoAgendaConst.citaMedica),
          isTrue,
        );
      });

      test('excluye eventos fuera del rango solicitado', () async {
        // El evento de mareos (1102) es del 2026-05-28, fuera de junio.
        final eventos = await datasource.getEventosSaludDelMes(
          personaId: DemoSeed.personaAliciaId,
          desde: DateTime(2026, 6, 1),
          hasta: DateTime(2026, 7, 1),
        );
        expect(eventos.any((e) => e.id == 1102), isFalse);
      });

      test('retorna vacío para ID inexistente', () async {
        final eventos = await datasource.getEventosSaludDelMes(
          personaId: 99999,
          desde: DateTime(2026, 6, 1),
          hasta: DateTime(2026, 7, 1),
        );
        expect(eventos, isEmpty);
      });
    });

    // ─── agregarNota ───────────────────────────────────────────────────────────

    group('agregarNota', () {
      // El evento de vacuna antigripal (1104) no tiene notas en el seed.
      test('agrega una nota embebida al evento', () async {
        await datasource.agregarNota(
          eventoSaludId: 1104,
          contenido: 'Contenido de test.',
        );

        final eventos = await datasource.getEventosSaludDelMes(
          personaId: DemoSeed.personaAliciaId,
          desde: DateTime(2026, 6, 1),
          hasta: DateTime(2026, 7, 1),
        );
        final evento = eventos.firstWhere((e) => e.id == 1104);
        expect(
          evento.notas.any((n) => n.contenido == 'Contenido de test.'),
          isTrue,
        );
      });

      test('la nota creada recibe un id generado mayor a 0', () async {
        await datasource.agregarNota(
          eventoSaludId: 1104,
          contenido: 'Otra nota.',
        );

        final eventos = await datasource.getEventosSaludDelMes(
          personaId: DemoSeed.personaAliciaId,
          desde: DateTime(2026, 6, 1),
          hasta: DateTime(2026, 7, 1),
        );
        final evento = eventos.firstWhere((e) => e.id == 1104);
        final nota = evento.notas.firstWhere(
          (n) => n.contenido == 'Otra nota.',
        );
        expect(nota.id, greaterThan(0));
        expect(nota.eventoSaludId, 1104);
      });
    });
  });
}
