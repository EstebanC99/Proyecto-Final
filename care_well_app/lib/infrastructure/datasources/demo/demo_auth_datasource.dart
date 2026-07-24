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
  Future<void> register(RegistroData data) async {
    await Future.delayed(Duration.zero);
    final existeEmail = _usuarios.any((u) => u.persona.email == data.email);
    if (existeEmail) throw const CuentaExistenteException();

    // La validación de identidad por foto del documento es solo-API: en demo
    // se ignora `imagenDocumento` (no-op), igual que la verificación por OTP.
    final personaId = _nextId++;
    final persona = Persona(
      id: personaId,
      nombre: data.nombre,
      apellido: data.apellido,
      documento: data.documento,
      fechaNacimiento: data.fechaNacimiento,
      email: data.email,
      telefono: data.telefono,
      imagen: data.imagen,
    );
    _personas.add(persona);

    final usuario = Usuario(
      id: _nextId++,
      persona: persona,
      contrasena: data.contrasena,
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
  Future<void> confirmarResetContrasena({
    required String email,
    required String codigo,
    required String contrasenaNueva,
  }) async {
    // Modo demo en desuso: devuelve éxito sin validar nada.
    await Future.delayed(Duration.zero);
  }

  // Verificación de email por OTP: no soportada en demo (feature solo-API).
  @override
  Future<void> reenviarCodigoVerificacion(String email) async {
    throw UnimplementedError(
      'Verificación de email por OTP no soportada en modo demo.',
    );
  }

  @override
  Future<void> verificarEmail(String email, String codigo) async {
    throw UnimplementedError(
      'Verificación de email por OTP no soportada en modo demo.',
    );
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

  @override
  Future<void> crearCredenciales({
    required String email,
    required String contrasena,
    required String imagenDocumento,
  }) async {
    await Future.delayed(Duration.zero);

    // La validación de identidad por foto del documento es solo-API: en demo
    // se ignora `imagenDocumento` (no-op), igual que en el registro.

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
  }
}
