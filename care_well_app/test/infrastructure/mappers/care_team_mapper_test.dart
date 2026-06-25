import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/infrastructure/mappers/mappers.dart';
import 'package:care_well_app/infrastructure/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── Fixtures ──────────────────────────────────────────────────────────────

  final personaJson = {
    'id': 5,
    'nombre': 'Alicia',
    'apellido': 'López',
    'documento': '12345678',
    'fechaNacimiento': '1940-03-15T00:00:00',
    'email': 'alicia@mail.com',
    'telefono': '2994001122',
    'imagenPath': null,
  };

  final colaboradorJson = {
    'id': 3,
    'nombre': 'María',
    'apellido': 'García',
    'documento': '28456789',
    'fechaNacimiento': '1985-03-14T00:00:00',
    'email': 'maria@mail.com',
    'telefono': null,
    'imagenPath': null,
  };

  final asignacionJson = {
    'id': 1,
    'persona': personaJson,
    'colaborador': colaboradorJson,
    'rol': {'id': 1, 'descripcion': 'Responsable'},
    'estado': {'id': 1, 'descripcion': 'Activa'},
    'fechaAlta': '2025-01-10T00:00:00',
    'permisos': [
      {'id': 2, 'descripcion': 'Ver agenda'},
    ],
  };

  // ── PersonaApiMapper ──────────────────────────────────────────────────────

  group('PersonaApiMapper', () {
    test('json → model → entity mapea campos correctamente', () {
      final model = PersonaApiModel.fromJson(personaJson);
      final entity = PersonaApiMapper.fromModel(model);

      expect(entity.id, 5);
      expect(entity.nombre, 'Alicia');
      expect(entity.apellido, 'López');
      expect(entity.documento, '12345678');
      expect(entity.fechaNacimiento, DateTime(1940, 3, 15));
      expect(entity.email, 'alicia@mail.com');
      expect(entity.telefono, '2994001122');
      expect(entity.imagen, isNull);
    });

    test('fechaNacimiento null no lanza excepción', () {
      final json = Map<String, dynamic>.from(personaJson)
        ..['fechaNacimiento'] = null;
      final model = PersonaApiModel.fromJson(json);
      final entity = PersonaApiMapper.fromModel(model);
      expect(entity.fechaNacimiento, isNull);
    });

    test('imagenPath no null se mapea a imagen', () {
      final json = Map<String, dynamic>.from(personaJson)
        ..['imagenPath'] = 'https://example.com/foto.jpg';
      final model = PersonaApiModel.fromJson(json);
      final entity = PersonaApiMapper.fromModel(model);
      expect(entity.imagen, 'https://example.com/foto.jpg');
    });
  });

  // ── AsignacionCuidadoApiMapper ────────────────────────────────────────────

  group('AsignacionCuidadoApiMapper', () {
    test('json → model → entity mapea todos los campos', () {
      final model = AsignacionCuidadoApiModel.fromJson(asignacionJson);
      final entity = AsignacionCuidadoApiMapper.fromModel(model);

      expect(entity.id, 1);
      expect(entity.personaCuidada.id, 5);
      expect(entity.personaCuidada.nombre, 'Alicia');
      expect(entity.personaColaborador.id, 3);
      expect(entity.personaColaborador.nombre, 'María');
      expect(entity.rol.id, RolesCuidadoConst.responsable);
      expect(entity.rol.descripcion, 'Responsable');
      expect(entity.estado.id, EstadosAsignacionConst.activa);
      expect(entity.estado.descripcion, 'Activa');
      expect(entity.fechaAlta, DateTime(2025, 1, 10));
    });

    test('permisos se mapean correctamente', () {
      final model = AsignacionCuidadoApiModel.fromJson(asignacionJson);
      final entity = AsignacionCuidadoApiMapper.fromModel(model);

      expect(entity.permisos, hasLength(1));
      final permiso = entity.permisos.first;
      expect(permiso.id, 2);
      expect(permiso.descripcion, 'Ver agenda');
      expect(permiso.codigo.id, 2);
      expect(permiso.codigo.descripcion, 'Ver agenda');
    });

    test('permisos vacíos produce lista vacía', () {
      final json = Map<String, dynamic>.from(asignacionJson)
        ..['permisos'] = <dynamic>[];
      final model = AsignacionCuidadoApiModel.fromJson(json);
      final entity = AsignacionCuidadoApiMapper.fromModel(model);
      expect(entity.permisos, isEmpty);
    });

    test('entity es de tipo AsignacionCuidado', () {
      final model = AsignacionCuidadoApiModel.fromJson(asignacionJson);
      final entity = AsignacionCuidadoApiMapper.fromModel(model);
      expect(entity, isA<AsignacionCuidado>());
    });

    test('personaCuidada y personaColaborador son entidades Persona', () {
      final model = AsignacionCuidadoApiModel.fromJson(asignacionJson);
      final entity = AsignacionCuidadoApiMapper.fromModel(model);
      expect(entity.personaCuidada, isA<Persona>());
      expect(entity.personaColaborador, isA<Persona>());
    });
  });

  // ── CatalogoItemModel ─────────────────────────────────────────────────────

  group('CatalogoItemModel', () {
    test('fromJson deserializa id y descripcion', () {
      final model = CatalogoItemModel.fromJson({
        'id': 10,
        'descripcion': 'Ejemplo',
      });
      expect(model.id, 10);
      expect(model.descripcion, 'Ejemplo');
    });
  });
}
