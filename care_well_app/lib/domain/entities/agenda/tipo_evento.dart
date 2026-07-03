import '../base_entity.dart';

/// Tipo de evento de agenda (catálogo persistido).
///
/// [agendable] indica si el tipo puede seleccionarse al crear un evento.
class TipoEvento extends BaseEntity {
  final String descripcion;
  final bool agendable;

  const TipoEvento({
    required super.id,
    required this.descripcion,
    this.agendable = true,
  });

  @override
  TipoEvento copyWith({int? id, String? descripcion, bool? agendable}) {
    return TipoEvento(
      id: id ?? this.id,
      descripcion: descripcion ?? this.descripcion,
      agendable: agendable ?? this.agendable,
    );
  }
}
