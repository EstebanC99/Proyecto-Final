import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/infrastructure/mappers/mappers.dart';
import 'package:care_well_app/infrastructure/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EstadoUsuarioMapper', () {
    test('fromModel activo produce entidad con id correcto', () {
      final model = EstadoUsuarioModel(
        id: EstadosUsuarioConst.activo,
        descripcion: 'Activo',
      );
      final entity = EstadoUsuarioMapper.fromModel(model);
      expect(entity.id, EstadosUsuarioConst.activo);
      expect(entity.descripcion, 'Activo');
    });

    test('fromModel suspendido produce entidad con id correcto', () {
      final model = EstadoUsuarioModel(
        id: EstadosUsuarioConst.suspendido,
        descripcion: 'Suspendido',
      );
      final entity = EstadoUsuarioMapper.fromModel(model);
      expect(entity.id, EstadosUsuarioConst.suspendido);
    });

    test('json → model → entity produce la entidad esperada', () {
      final json = {'id': EstadosUsuarioConst.activo, 'descripcion': 'Activo'};
      final model = EstadoUsuarioModel.fromJson(json);
      final entity = EstadoUsuarioMapper.fromModel(model);
      expect(entity.id, EstadosUsuarioConst.activo);
      expect(entity.descripcion, 'Activo');
    });
  });

  group('UsuarioMapper', () {
    final personaModel = PersonaModel(
      id: 1,
      nombre: 'María',
      apellido: 'García',
      email: 'maria@example.com',
      telefono: '',
      documento: '',
      fechaNacimiento: DateTime(1990, 1, 1),
      imagenPath: null,
    );

    final estadoModel = EstadoUsuarioModel(
      id: EstadosUsuarioConst.activo,
      descripcion: 'Activo',
    );

    final usuarioModel = UsuarioModel(
      id: 101,
      nombreUsuario: 'maria@example.com',
      personaModel: personaModel,
      estadoModel: estadoModel,
    );

    test('fromModel produce entidad con id y estado correcto', () {
      final entity = UsuarioMapper.fromModel(usuarioModel);
      expect(entity.id, 101);
      expect(entity.estado.id, EstadosUsuarioConst.activo);
    });

    test('fromModel asigna persona correctamente', () {
      final entity = UsuarioMapper.fromModel(usuarioModel);
      expect(entity.persona.id, 1);
      expect(entity.persona.nombre, 'María');
    });
  });
}
