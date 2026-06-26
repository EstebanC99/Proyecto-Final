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
    'telefono': '2994000000',
    'imagenPath': null,
  };

  // Construimos el AsignacionCuidadoModel directamente para aislar el test del
  // mapper (model→entity) del parsing JSON, cuya responsabilidad corresponde
  // al test del modelo. La construcción directa evita el bug de inferencia de
  // tipo en AsignacionCuidadoModel.fromJson (ver nota al arquitecto).
  AsignacionCuidadoModel _buildAsignacionModel({
    List<PermisoCuidadoModel> permisos = const [],
  }) => AsignacionCuidadoModel(
    id: 1,
    persona: PersonaModel.fromJson(personaJson),
    colaborador: PersonaModel.fromJson(colaboradorJson),
    rol: RolCuidadoModel.fromJson({'id': 1, 'descripcion': 'Responsable'}),
    estado: EstadoAsignacionCuidadoModel.fromJson({
      'id': 1,
      'descripcion': 'Activa',
    }),
    fechaAlta: '2025-01-10T00:00:00',
    permisos: permisos,
  );

  // ── PersonaMapper ─────────────────────────────────────────────────────────

  group('PersonaMapper', () {
    test('json → model → entity mapea campos correctamente', () {
      final model = PersonaModel.fromJson(personaJson);
      final entity = PersonaMapper.fromModel(model);

      expect(entity.id, 5);
      expect(entity.nombre, 'Alicia');
      expect(entity.apellido, 'López');
      expect(entity.documento, '12345678');
      expect(entity.fechaNacimiento, DateTime(1940, 3, 15));
      expect(entity.email, 'alicia@mail.com');
      expect(entity.telefono, '2994001122');
      expect(entity.imagen, isNull);
    });
  });

  // ── AsignacionCuidadoMapper ───────────────────────────────────────────────

  group('AsignacionCuidadoMapper', () {
    test('model → entity mapea todos los campos', () {
      final model = _buildAsignacionModel();
      final entity = AsignacionCuidadoMapper.fromModel(model);

      expect(entity.id, 1);
      expect(entity.personaCuidada.id, 5);
      expect(entity.personaCuidada.nombre, 'Alicia');
      expect(entity.colaborador.id, 3);
      expect(entity.colaborador.nombre, 'María');
      expect(entity.rol.id, RolesCuidadoConst.responsable);
      expect(entity.rol.descripcion, 'Responsable');
      expect(entity.estado.id, EstadosAsignacionConst.activa);
      expect(entity.estado.descripcion, 'Activa');
      expect(entity.fechaAlta, DateTime(2025, 1, 10));
    });

    test('permisos se mapean correctamente', () {
      final model = _buildAsignacionModel(
        permisos: [PermisoCuidadoModel(id: 2, descripcion: 'Ver agenda')],
      );
      final entity = AsignacionCuidadoMapper.fromModel(model);

      expect(entity.permisos, hasLength(1));
      final permiso = entity.permisos.first;
      expect(permiso.id, 2);
      expect(permiso.descripcion, 'Ver agenda');
    });

    test('permisos vacíos produce lista vacía', () {
      final model = _buildAsignacionModel();
      final entity = AsignacionCuidadoMapper.fromModel(model);
      expect(entity.permisos, isEmpty);
    });

    test('entity es de tipo AsignacionCuidado', () {
      final model = _buildAsignacionModel();
      final entity = AsignacionCuidadoMapper.fromModel(model);
      expect(entity, isA<AsignacionCuidado>());
    });

    test('personaCuidada y colaborador son entidades Persona', () {
      final model = _buildAsignacionModel();
      final entity = AsignacionCuidadoMapper.fromModel(model);
      expect(entity.personaCuidada, isA<Persona>());
      expect(entity.colaborador, isA<Persona>());
    });
  });
}
