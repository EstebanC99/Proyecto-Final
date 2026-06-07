import '../base_entity.dart';
import '../shared/persona.dart';

/// Estado de la cuenta de un [Usuario].
enum EstadoUsuario {
  /// Cuenta activa y operativa.
  activo,

  /// Cuenta suspendida temporalmente por el sistema o el administrador.
  suspendido,

  /// Cuenta eliminada (baja lógica).
  eliminado,
}

/// Entidad de autenticación: persona con credenciales de acceso.
///
/// Un Usuario es una [Persona] que puede iniciar sesión. La contraseña
/// nunca se almacena en la entidad; el campo [contrasenaHash] es solo
/// informativo para el dominio (el hash lo gestiona el backend).
class Usuario extends BaseEntity {
  /// Persona asociada a este usuario.
  final Persona persona;

  final String nombreUsuario;

  /// Hash de la contraseña (nunca texto plano). Puede ser nulo en el cliente.
  final String? contrasenaHash;

  final EstadoUsuario estado;

  const Usuario({
    required super.id,
    required this.persona,
    required this.nombreUsuario,
    this.contrasenaHash,
    this.estado = EstadoUsuario.activo,
  });

  @override
  Usuario copyWith({
    String? id,
    Persona? persona,
    String? nombreUsuario,
    String? contrasenaHash,
    EstadoUsuario? estado,
  }) {
    return Usuario(
      id: id ?? this.id,
      persona: persona ?? this.persona,
      nombreUsuario: nombreUsuario ?? this.nombreUsuario,
      contrasenaHash: contrasenaHash ?? this.contrasenaHash,
      estado: estado ?? this.estado,
    );
  }
}
