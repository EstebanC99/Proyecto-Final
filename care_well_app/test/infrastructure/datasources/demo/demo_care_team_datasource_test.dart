import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/infrastructure/datasources/demo/demo_care_team_datasource.dart';
import 'package:care_well_app/infrastructure/datasources/demo/demo_seed.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../_fakes/test_fixtures.dart';

void main() {
  group('DemoCareTeamDatasource', () {
    late DemoCareTeamDatasource datasource;

    setUp(() => datasource = DemoCareTeamDatasource());

    group('getAsignacionesByPersonaCuidada', () {
      test('retorna asignaciones de Alicia', () async {
        final result = await datasource.getAsignacionesByPersonaCuidada(
          DemoSeed.personaAliciaId,
        );
        expect(result, isNotEmpty);
        expect(
          result.every((a) => a.personaCuidada.id == DemoSeed.personaAliciaId),
          isTrue,
        );
      });

      test('retorna lista vacía para ID inexistente', () async {
        final result = await datasource.getAsignacionesByPersonaCuidada(99999);
        expect(result, isEmpty);
      });
    });

    group('getAsignacionesByColaborador', () {
      test('retorna asignaciones de María como colaboradora', () async {
        final result = await datasource.getAsignacionesByColaborador(
          DemoSeed.personaMariaId,
        );
        expect(result, isNotEmpty);
        expect(
          result.every((a) => a.colaborador.id == DemoSeed.personaMariaId),
          isTrue,
        );
      });

      test('retorna asignaciones de Carlos como colaborador', () async {
        final result = await datasource.getAsignacionesByColaborador(
          DemoSeed.personaCarlosId,
        );
        expect(result.length, greaterThanOrEqualTo(1));
      });

      test('retorna lista vacía para colaborador sin asignaciones', () async {
        final result = await datasource.getAsignacionesByColaborador(99999);
        expect(result, isEmpty);
      });
    });

    group('crearAsignacion', () {
      test('agrega la asignación y genera un nuevo ID mayor a 0', () async {
        final nueva = AsignacionCuidado(
          id: 0,
          personaCuidada: DemoSeed.personaAlicia,
          colaborador: DemoSeed.personaRoberto,
          rol: DemoSeed.rolCuidadoCuidador,
          estado: estadoAsignacionActiva,
          fechaAlta: DateTime(2026, 1, 1),
        );
        final creada = await datasource.crearAsignacion(nueva);
        expect(creada.id, greaterThan(0));

        final lista = await datasource.getAsignacionesByPersonaCuidada(
          DemoSeed.personaAliciaId,
        );
        expect(lista.any((a) => a.id == creada.id), isTrue);
      });
    });

    group('actualizarAsignacion', () {
      test('actualiza la asignación existente', () async {
        final original = await datasource.getAsignacionesByPersonaCuidada(
          DemoSeed.personaAliciaId,
        );
        expect(original, isNotEmpty);

        final asignacion = original.first;
        final actualizada = asignacion.copyWith(
          estado: estadoAsignacionInactiva,
        );
        final resultado = await datasource.actualizarAsignacion(actualizada);
        expect(resultado.estado.id, EstadosAsignacionConst.inactiva);
      });

      test('lanza excepción si no existe', () async {
        final falsa = AsignacionCuidado(
          id: 99999,
          personaCuidada: DemoSeed.personaAlicia,
          colaborador: DemoSeed.personaCarlos,
          rol: DemoSeed.rolCuidadoResponsable,
          estado: estadoAsignacionActiva,
          fechaAlta: DateTime.now(),
        );
        expect(() => datasource.actualizarAsignacion(falsa), throwsException);
      });
    });

    group('eliminarAsignacion', () {
      test('elimina la asignación correctamente', () async {
        final nueva = await datasource.crearAsignacion(
          AsignacionCuidado(
            id: 0,
            personaCuidada: DemoSeed.personaAlicia,
            colaborador: DemoSeed.personaLaura,
            rol: DemoSeed.rolCuidadoCuidador,
            estado: estadoAsignacionActiva,
            fechaAlta: DateTime.now(),
          ),
        );
        await datasource.eliminarAsignacion(nueva.id);

        final lista = await datasource.getAsignacionesByPersonaCuidada(
          DemoSeed.personaAliciaId,
        );
        expect(lista.any((a) => a.id == nueva.id), isFalse);
      });

      test('lanza excepción si el ID no existe', () async {
        expect(() => datasource.eliminarAsignacion(99999), throwsException);
      });
    });
  });
}
