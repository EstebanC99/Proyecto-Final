import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/infrastructure/mappers/mappers.dart';
import 'package:care_well_app/infrastructure/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PermisoMapper', () {
    final permiso = Permiso(
      id: 'prm_001',
      codigo: CodigoPermiso.verFichaSalud,
      descripcion: 'Ver ficha de salud',
    );

    final model = PermisoModel(
      id: 'prm_001',
      codigo: 'verFichaSalud',
      descripcion: 'Ver ficha de salud',
    );

    test('entity → model → entity produce entidad equivalente', () {
      final roundTrip = PermisoMapper.fromModel(PermisoMapper.toModel(permiso));
      expect(roundTrip.id, permiso.id);
      expect(roundTrip.codigo, permiso.codigo);
      expect(roundTrip.descripcion, permiso.descripcion);
    });

    test('json → model → entity → model → json produce el mismo JSON', () {
      final json = model.toJson();
      final modelFromJson = PermisoModel.fromJson(json);
      final entity = PermisoMapper.fromModel(modelFromJson);
      final modelBack = PermisoMapper.toModel(entity);
      expect(modelBack.toJson(), json);
    });
  });

  group('RolMapper', () {
    final rol = Rol(id: 'rol_001', nombre: RolCuidado.responsable);

    test('entity → model → entity produce entidad equivalente', () {
      final roundTrip = RolMapper.fromModel(RolMapper.toModel(rol));
      expect(roundTrip.id, rol.id);
      expect(roundTrip.nombre, rol.nombre);
    });

    test('json → model → entity → model → json produce el mismo JSON', () {
      final json = RolMapper.toModel(rol).toJson();
      final modelFromJson = RolModel.fromJson(json);
      final entity = RolMapper.fromModel(modelFromJson);
      final modelBack = RolMapper.toModel(entity);
      expect(modelBack.toJson(), json);
    });
  });

  group('AsignacionCuidadoMapper', () {
    final personaCuidada = Persona(
      id: 'per_001',
      nombre: 'Alicia',
      apellido: 'Rodríguez',
    );

    final personaColaborador = Persona(
      id: 'per_002',
      nombre: 'Carlos',
      apellido: 'Pérez',
    );

    final rol = Rol(id: 'rol_001', nombre: RolCuidado.responsable);

    final asignacion = AsignacionCuidado(
      id: 'asi_001',
      personaCuidada: personaCuidada,
      personaColaborador: personaColaborador,
      rol: rol,
      estado: EstadoAsignacion.activa,
      fechaAlta: DateTime(2024, 1, 10),
    );

    final model = AsignacionCuidadoModel(
      id: 'asi_001',
      personaCuidadaId: 'per_001',
      personaColaboradorId: 'per_002',
      rolId: 'rol_001',
      estado: 'activa',
      fechaAlta: '2024-01-10T00:00:00.000',
    );

    test('entity → model → entity produce entidad equivalente', () {
      final roundTrip = AsignacionCuidadoMapper.fromModel(
        AsignacionCuidadoMapper.toModel(asignacion),
        personaCuidada: personaCuidada,
        personaColaborador: personaColaborador,
        rol: rol,
      );
      expect(roundTrip.id, asignacion.id);
      expect(roundTrip.estado, asignacion.estado);
      expect(
        roundTrip.fechaAlta.toIso8601String(),
        asignacion.fechaAlta.toIso8601String(),
      );
    });

    test('json → model → entity → model → json produce el mismo JSON', () {
      final json = model.toJson();
      final modelFromJson = AsignacionCuidadoModel.fromJson(json);
      final entity = AsignacionCuidadoMapper.fromModel(
        modelFromJson,
        personaCuidada: personaCuidada,
        personaColaborador: personaColaborador,
        rol: rol,
      );
      final modelBack = AsignacionCuidadoMapper.toModel(entity);
      expect(modelBack.toJson(), json);
    });
  });
}
