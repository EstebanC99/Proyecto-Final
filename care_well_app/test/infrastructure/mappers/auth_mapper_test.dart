import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/infrastructure/mappers/mappers.dart';
import 'package:care_well_app/infrastructure/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UsuarioMapper', () {
    final persona = Persona(
      id: 'per_001',
      nombre: 'María',
      apellido: 'García',
      email: 'maria@example.com',
    );

    final usuario = Usuario(
      id: 'usr_001',
      persona: persona,
      nombreUsuario: 'maria.garcia',
      contrasenaHash: 'hash123',
      estado: EstadoUsuario.activo,
    );

    final model = UsuarioModel(
      id: 'usr_001',
      personaId: 'per_001',
      nombreUsuario: 'maria.garcia',
      contrasenaHash: 'hash123',
      estado: 'activo',
    );

    test('entity → model → entity produce entidad equivalente', () {
      final roundTrip = UsuarioMapper.fromModel(
        UsuarioMapper.toModel(usuario),
        persona,
      );
      expect(roundTrip.id, usuario.id);
      expect(roundTrip.nombreUsuario, usuario.nombreUsuario);
      expect(roundTrip.contrasenaHash, usuario.contrasenaHash);
      expect(roundTrip.estado, usuario.estado);
      expect(roundTrip.persona.id, persona.id);
    });

    test('json → model → entity → model → json produce el mismo JSON', () {
      final json = model.toJson();
      final modelFromJson = UsuarioModel.fromJson(json);
      final entity = UsuarioMapper.fromModel(modelFromJson, persona);
      final modelBack = UsuarioMapper.toModel(entity);
      expect(modelBack.toJson(), json);
    });

    test('estado suspendido se serializa y deserializa correctamente', () {
      final suspendido = usuario.copyWith(estado: EstadoUsuario.suspendido);
      final roundTrip = UsuarioMapper.fromModel(
        UsuarioMapper.toModel(suspendido),
        persona,
      );
      expect(roundTrip.estado, EstadoUsuario.suspendido);
    });
  });
}
