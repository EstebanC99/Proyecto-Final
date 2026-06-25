import '../auth/usuario.dart';
import '../base_entity.dart';

/// Registro de aceptación de una versión de los Términos y Condiciones.
class AceptacionTerminos extends BaseEntity {
  /// Usuario que aceptó los términos.
  final Usuario usuario;

  /// Versión del documento aceptado (p. ej. `'1.0'`).
  final String version;

  final DateTime fechaAceptacion;

  const AceptacionTerminos({
    required super.id,
    required this.usuario,
    required this.version,
    required this.fechaAceptacion,
  });

  @override
  AceptacionTerminos copyWith({
    int? id,
    Usuario? usuario,
    String? version,
    DateTime? fechaAceptacion,
  }) {
    return AceptacionTerminos(
      id: id ?? this.id,
      usuario: usuario ?? this.usuario,
      version: version ?? this.version,
      fechaAceptacion: fechaAceptacion ?? this.fechaAceptacion,
    );
  }
}
