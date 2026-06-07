import '../../../domain/datasources/datasources.dart';
import '../../../domain/entities/entities.dart';
import 'demo_seed.dart';

/// Implementación demo (en memoria) de [AuthDatasource].
///
/// Valida credenciales contra los datos semilla. No requiere servidor.
class DemoAuthDatasource implements AuthDatasource {
  /// Lista mutable de usuarios registrados en la sesión demo.
  final List<Usuario> _usuarios = [DemoSeed.usuarioMaria];

  /// Lista de personas conocidas por el sistema.
  final List<Persona> _personas = [
    DemoSeed.personaMaria,
    DemoSeed.personaAlicia,
    DemoSeed.personaCarlos,
    DemoSeed.personaLaura,
    // Roberto Sánchez: persona sin credenciales para caso de prueba US-04.
    DemoSeed.personaRoberto,
  ];

  @override
  Future<Usuario> login(String nombreUsuario, String contrasena) async {
    await Future.delayed(Duration.zero);
    // DESVÍO MVP: el contrato usa nombreUsuario pero la UI envía email.
    // Se acepta ambos hasta que el dominio unifique el identificador.
    final usuario = _usuarios
        .where(
          (u) =>
              u.nombreUsuario == nombreUsuario ||
              u.persona.email == nombreUsuario,
        )
        .firstOrNull;
    if (usuario == null || usuario.contrasenaHash != contrasena) {
      throw Exception('Credenciales inválidas.');
    }
    if (usuario.estado == EstadoUsuario.eliminado) {
      throw Exception('La cuenta fue eliminada.');
    }
    if (usuario.estado == EstadoUsuario.suspendido) {
      throw Exception('La cuenta está suspendida.');
    }
    return usuario;
  }

  @override
  Future<Usuario> register({
    required String nombre,
    required String apellido,
    required String email,
    required String nombreUsuario,
    required String contrasena,
  }) async {
    await Future.delayed(Duration.zero);
    final existeUsuario = _usuarios.any(
      (u) => u.nombreUsuario == nombreUsuario,
    );
    if (existeUsuario) throw Exception('El nombre de usuario ya está en uso.');
    final existeEmail = _usuarios.any((u) => u.persona.email == email);
    if (existeEmail) throw Exception('El email ya está registrado.');

    final ts = DateTime.now().millisecondsSinceEpoch.toString();
    final persona = Persona(
      id: 'per_$ts',
      nombre: nombre,
      apellido: apellido,
      email: email,
    );
    _personas.add(persona);

    final usuario = Usuario(
      id: 'usr_$ts',
      persona: persona,
      nombreUsuario: nombreUsuario,
      contrasenaHash: contrasena,
      estado: EstadoUsuario.activo,
    );
    _usuarios.add(usuario);
    return usuario;
  }

  @override
  Future<void> solicitarRecuperacionContrasena(String email) async {
    await Future.delayed(Duration.zero);
    // En demo simplemente simula que el correo fue enviado sin validar.
  }

  @override
  Future<void> logout() async {
    await Future.delayed(Duration.zero);
    // En demo no hay sesión server-side que invalidar.
  }

  @override
  Future<void> eliminarCuenta(String usuarioId) async {
    await Future.delayed(Duration.zero);
    final idx = _usuarios.indexWhere((u) => u.id == usuarioId);
    if (idx < 0) throw Exception('Usuario no encontrado.');
    // Baja lógica: reemplaza con estado eliminado.
    _usuarios[idx] = _usuarios[idx].copyWith(estado: EstadoUsuario.eliminado);
  }

  @override
  Future<void> cambiarContrasena({
    required String usuarioId,
    required String contrasenaActual,
    required String contrasenaNueva,
  }) async {
    await Future.delayed(Duration.zero);
    final idx = _usuarios.indexWhere((u) => u.id == usuarioId);
    if (idx < 0) throw Exception('Usuario no encontrado.');
    if (_usuarios[idx].contrasenaHash != contrasenaActual) {
      throw Exception('La contraseña actual es incorrecta.');
    }
    _usuarios[idx] = _usuarios[idx].copyWith(contrasenaHash: contrasenaNueva);
  }

  @override
  Future<Usuario> actualizarPerfil({
    required String usuarioId,
    String? email,
    String? telefono,
    String? documento,
  }) async {
    await Future.delayed(Duration.zero);
    final idx = _usuarios.indexWhere((u) => u.id == usuarioId);
    if (idx < 0) throw Exception('Usuario no encontrado.');

    final personaActual = _usuarios[idx].persona;
    final personaActualizada = personaActual.copyWith(
      email: email ?? personaActual.email,
      telefono: telefono ?? personaActual.telefono,
      documento: documento ?? personaActual.documento,
    );

    // Actualizar en la lista de personas si existe (por id)
    final personaIdx = _personas.indexWhere((p) => p.id == personaActual.id);
    if (personaIdx >= 0) {
      _personas[personaIdx] = personaActualizada;
    }

    final usuarioActualizado = _usuarios[idx].copyWith(
      persona: personaActualizada,
    );
    _usuarios[idx] = usuarioActualizado;
    return usuarioActualizado;
  }

  @override
  Future<Usuario> crearCredenciales({
    required String email,
    required String nombreUsuario,
    required String contrasena,
  }) async {
    await Future.delayed(Duration.zero);
    // Verificar que no exista ya un usuario con ese nombreUsuario.
    final existeUsuario = _usuarios.any(
      (u) => u.nombreUsuario == nombreUsuario,
    );
    if (existeUsuario) throw Exception('El nombre de usuario ya está en uso.');

    // Buscar persona preexistente sin credenciales.
    final persona = _personas.where((p) => p.email == email).firstOrNull;
    if (persona == null) {
      throw Exception('Persona no encontrada. Verificá el email ingresado.');
    }

    // Verificar que la persona no tenga ya un Usuario asociado.
    final yaTieneCredenciales = _usuarios.any(
      (u) => u.persona.id == persona.id,
    );
    if (yaTieneCredenciales) {
      throw Exception('Esta persona ya tiene credenciales creadas.');
    }

    final ts = DateTime.now().millisecondsSinceEpoch.toString();
    final usuario = Usuario(
      id: 'usr_$ts',
      persona: persona,
      nombreUsuario: nombreUsuario,
      contrasenaHash: contrasena,
      estado: EstadoUsuario.activo,
    );
    _usuarios.add(usuario);
    return usuario;
  }
}
