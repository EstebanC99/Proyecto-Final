import 'dart:typed_data';

import 'package:care_well_app/domain/entities/entities.dart';

abstract class PersonaRepository {
  Future<Persona> getById(int id);

  /// Devuelve los bytes de la imagen de perfil de la persona [id], o `null`
  /// si la persona no tiene imagen cargada.
  Future<Uint8List?> getImagen(int id);

  // TODO: evaluar si se elimina cuando todos los flujos usen AsignacionCuidadoRepository.
  Future<List<Persona>> getDependientesByUsuario(int usuarioId);

  Future<Persona> crear(Persona persona);

  Future<Persona> actualizar(Persona persona);

  Future<void> eliminar(int id);
}
