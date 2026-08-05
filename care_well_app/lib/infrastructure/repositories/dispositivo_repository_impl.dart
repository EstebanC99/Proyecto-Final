import 'package:care_well_app/domain/datasources/datasources.dart';
import 'package:care_well_app/domain/repositories/repositories.dart';

class DispositivoRepositoryImpl implements DispositivoRepository {
  final DispositivoDatasource _datasource;

  const DispositivoRepositoryImpl(this._datasource);

  @override
  Future<void> registrar({required String token, required int plataforma}) =>
      _datasource.registrar(token: token, plataforma: plataforma);

  @override
  Future<void> eliminar({required String token}) =>
      _datasource.eliminar(token: token);
}
