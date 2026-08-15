import 'package:care_well_app/domain/datasources/datasources.dart';
import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/infrastructure/repositories/summary_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

/// Datasource falso que registra los argumentos recibidos para comprobar que
/// [SummaryRepositoryImpl] delega correctamente.
class _FakeSummaryDatasource implements SummaryDatasource {
  ({int personaId, bool forzarActualizacion})? args;
  final ResumenInteligente _resultado;

  _FakeSummaryDatasource(this._resultado);

  @override
  Future<ResumenInteligente> obtenerResumen({
    required int personaId,
    bool forzarActualizacion = false,
  }) async {
    args = (personaId: personaId, forzarActualizacion: forzarActualizacion);
    return _resultado;
  }
}

void main() {
  group('SummaryRepositoryImpl', () {
    final resultado = ResumenInteligente(
      resumenAcotado: 'Resumen de prueba.',
      tieneDatos: true,
      generadoEn: DateTime(2026, 7, 30, 10),
    );

    test(
      'obtenerResumen delega personaId y forzarActualizacion por defecto',
      () async {
        final datasource = _FakeSummaryDatasource(resultado);
        final repository = SummaryRepositoryImpl(datasource);

        final res = await repository.obtenerResumen(personaId: 2);

        expect(datasource.args?.personaId, 2);
        expect(datasource.args?.forzarActualizacion, isFalse);
        expect(res, same(resultado));
      },
    );

    test('obtenerResumen propaga forzarActualizacion cuando se pide', () async {
      final datasource = _FakeSummaryDatasource(resultado);
      final repository = SummaryRepositoryImpl(datasource);

      await repository.obtenerResumen(personaId: 5, forzarActualizacion: true);

      expect(datasource.args?.personaId, 5);
      expect(datasource.args?.forzarActualizacion, isTrue);
    });
  });
}
