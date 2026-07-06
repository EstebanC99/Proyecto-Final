import 'package:care_well_app/domain/entities/agenda/tipo_evento.dart';

abstract class TipoEventoRepository {
  Future<List<TipoEvento>> obtenerTiposEvento();
}
