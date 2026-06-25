import '../../../domain/datasources/datasources.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/exceptions/exceptions.dart';
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

  /// Contador para IDs autogenerados en la sesión demo.
  int _nextId = 10000;

  @override
  Future<Usuario> login(String email, String contrasena) async {
    await Future.delayed(Duration.zero);
    final usuario = _usuarios
        .where((u) => u.persona.email == email)
        .firstOrNull;
    if (usuario == null || usuario.contrasena != contrasena) {
      throw const CredencialesInvalidasException();
    }
    if (usuario.estado.id == EstadosUsuarioConst.eliminado) {
      throw const CredencialesInvalidasException();
    }
    if (usuario.estado.id == EstadosUsuarioConst.suspendido) {
      throw const CredencialesInvalidasException();
    }
    return usuario;
  }

  @override
  Future<void> register({
    required String nombre,
    required String apellido,
    required String documento,
    required DateTime fechaNacimiento,
    required String email,
    String? telefono,
    required String contrasena,
  }) async {
    await Future.delayed(Duration.zero);
    final existeEmail = _usuarios.any((u) => u.persona.email == email);
    if (existeEmail) throw const CuentaExistenteException();

    final personaId = _nextId++;
    final persona = Persona(
      id: personaId,
      nombre: nombre,
      apellido: apellido,
      documento: documento,
      fechaNacimiento: fechaNacimiento,
      email: email,
      telefono: telefono,
    );
    _personas.add(persona);

    final usuario = Usuario(
      id: _nextId++,
      persona: persona,
      contrasena: contrasena,
      estado: DemoSeed.estadoActivo,
    );
    _usuarios.add(usuario);
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
  Future<void> eliminarCuenta(int usuarioId) async {
    await Future.delayed(Duration.zero);
    final idx = _usuarios.indexWhere((u) => u.id == usuarioId);
    if (idx < 0) throw const RecursoNoEncontradoException();
    // Baja lógica: reemplaza con estado eliminado.
    _usuarios[idx] = _usuarios[idx].copyWith(estado: DemoSeed.estadoEliminado);
  }

  @override
  Future<void> cambiarContrasena({
    required int usuarioId,
    required String contrasenaActual,
    required String contrasenaNueva,
  }) async {
    await Future.delayed(Duration.zero);
    final idx = _usuarios.indexWhere((u) => u.id == usuarioId);
    if (idx < 0) throw const RecursoNoEncontradoException();
    if (_usuarios[idx].contrasena != contrasenaActual) {
      throw const CredencialesInvalidasException();
    }
    _usuarios[idx] = _usuarios[idx].copyWith(contrasena: contrasenaNueva);
  }

  @override
  Future<Usuario> actualizarPerfil({
    required int usuarioId,
    String? email,
    String? telefono,
    String? documento,
  }) async {
    await Future.delayed(Duration.zero);
    final idx = _usuarios.indexWhere((u) => u.id == usuarioId);
    if (idx < 0) throw const RecursoNoEncontradoException();

    final personaActual = _usuarios[idx].persona;
    final personaActualizada = personaActual.copyWith(
      email: email ?? personaActual.email,
      telefono: telefono ?? personaActual.telefono,
      documento: documento ?? personaActual.documento,
    );

    // Actualizar en la lista de personas si existe (por id).
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

  // TODO: reemplazar por ApiAuthDatasource cuando el backend tenga el endpoint de activación de credenciales
  @override
  Future<Usuario> crearCredenciales({
    required String email,
    required String contrasena,
  }) async {
    await Future.delayed(Duration.zero);

    // Buscar persona preexistente sin credenciales.
    final persona = _personas.where((p) => p.email == email).firstOrNull;
    if (persona == null) throw const RecursoNoEncontradoException();

    // Verificar que la persona no tenga ya un Usuario asociado.
    final yaTieneCredenciales = _usuarios.any(
      (u) => u.persona.id == persona.id,
    );
    if (yaTieneCredenciales) throw const CuentaExistenteException();

    final usuario = Usuario(
      id: _nextId++,
      persona: persona,
      contrasena: contrasena,
      estado: DemoSeed.estadoActivo,
    );
    _usuarios.add(usuario);
    return usuario;
  }
}
