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
      test('retorna eventos de Alicia con tipos del enum ampliado', () async {
        final eventos = await datasource.getEventosSaludByPersona(
          DemoSeed.personaAliciaId,
        );
        expect(eventos, isNotEmpty);
        expect(
          eventos.every((e) => TipoEventoSalud.values.contains(e.tipo)),
          isTrue,
        );
      });

      test(
        'incluye evento de tipo citaMedica (nuevo valor del enum)',
        () async {
          final eventos = await datasource.getEventosSaludByPersona(
            DemoSeed.personaAliciaId,
          );
          expect(
            eventos.any((e) => e.tipo == TipoEventoSalud.citaMedica),
            isTrue,
          );
        },
      );

      test('retorna vacío para ID inexistente', () async {
        final eventos = await datasource.getEventosSaludByPersona('no_existe');
        expect(eventos, isEmpty);
      });
    });

    // ─── getNotasByEvento ──────────────────────────────────────────────────────

    group('getNotasByEvento', () {
      test('retorna notas del evento esa_003 del seed', () async {
        final notas = await datasource.getNotasByEvento('esa_003');
        expect(notas, isNotEmpty);
        expect(notas.every((n) => n.eventoSaludId == 'esa_003'), isTrue);
      });

      test('retorna vacío para evento sin notas', () async {
        final notas = await datasource.getNotasByEvento('esa_002');
        expect(notas, isEmpty);
      });
    });

    // ─── crearNota ─────────────────────────────────────────────────────────────

    group('crearNota', () {
      test('crea nota y la retorna con id generado', () async {
        final nota = NotaEvento(
          id: '',
          eventoSaludId: 'esa_001',
          autor: DemoSeed.personaMaria,
          fechaHora: DateTime.now(),
          contenido: 'Nueva nota de prueba.',
        );
        final creada = await datasource.crearNota(nota);
        expect(creada.id, isNotEmpty);
        expect(creada.contenido, 'Nueva nota de prueba.');
        expect(creada.eventoSaludId, 'esa_001');
      });

      test('nota creada aparece en getNotasByEvento', () async {
        final nota = NotaEvento(
          id: '',
          eventoSaludId: 'esa_002',
          autor: DemoSeed.personaMaria,
          fechaHora: DateTime.now(),
          contenido: 'Contenido de test.',
        );
        await datasource.crearNota(nota);
        final notas = await datasource.getNotasByEvento('esa_002');
        expect(notas.any((n) => n.contenido == 'Contenido de test.'), isTrue);
      });
    });
  });
}
