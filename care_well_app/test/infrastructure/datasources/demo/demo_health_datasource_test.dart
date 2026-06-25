import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/infrastructure/datasources/demo/demo_health_datasource.dart';
import 'package:care_well_app/infrastructure/datasources/demo/demo_seed.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DemoHealthDatasource', () {
    late DemoHealthDatasource datasource;

    setUp(() => datasource = DemoHealthDatasource());

    // ─── getEventosSaludByPersona ──────────────────────────────────────────────

    group('getEventosSaludByPersona', () {
      test('retorna eventos de Alicia', () async {
        final eventos = await datasource.getEventosSaludByPersona(
          DemoSeed.personaAliciaId,
        );
        expect(eventos, isNotEmpty);
      });

      test('incluye evento de tipo citaMedica en el seed', () async {
        final eventos = await datasource.getEventosSaludByPersona(
          DemoSeed.personaAliciaId,
        );
        expect(
          eventos.any((e) => e.tipo.id == TiposEventoSaludConst.citaMedica),
          isTrue,
        );
      });

      test('retorna vacío para ID inexistente', () async {
        final eventos = await datasource.getEventosSaludByPersona(99999);
        expect(eventos, isEmpty);
      });
    });

    // ─── getNotasByEvento ──────────────────────────────────────────────────────

    group('getNotasByEvento', () {
      // El seed tiene notas para eventoSaludControlCardiologico (id: 1103)
      test('retorna notas del evento 1103 del seed', () async {
        final notas = await datasource.getNotasByEvento(1103);
        expect(notas, isNotEmpty);
        expect(notas.every((n) => n.eventoSaludId == 1103), isTrue);
      });

      // El evento de vacuna antigripal (id: 1104) no tiene notas en el seed
      test('retorna vacío para evento sin notas', () async {
        final notas = await datasource.getNotasByEvento(1104);
        expect(notas, isEmpty);
      });
    });

    // ─── crearNota ─────────────────────────────────────────────────────────────

    group('crearNota', () {
      test('crea nota y la retorna con id generado mayor a 0', () async {
        final nota = NotaEvento(
          id: 0,
          eventoSaludId: 1101,
          autor: DemoSeed.personaMaria,
          fechaHora: DateTime.now(),
          contenido: 'Nueva nota de prueba.',
        );
        final creada = await datasource.crearNota(nota);
        expect(creada.id, greaterThan(0));
        expect(creada.contenido, 'Nueva nota de prueba.');
        expect(creada.eventoSaludId, 1101);
      });

      test('nota creada aparece en getNotasByEvento', () async {
        final nota = NotaEvento(
          id: 0,
          eventoSaludId: 1104,
          autor: DemoSeed.personaMaria,
          fechaHora: DateTime.now(),
          contenido: 'Contenido de test.',
        );
        await datasource.crearNota(nota);
        final notas = await datasource.getNotasByEvento(1104);
        expect(notas.any((n) => n.contenido == 'Contenido de test.'), isTrue);
      });
    });
  });
}
