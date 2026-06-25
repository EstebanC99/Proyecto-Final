import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/infrastructure/mappers/mappers.dart';
import 'package:care_well_app/infrastructure/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_fakes/test_fixtures.dart';

void main() {
  final persona = Persona(id: 1, nombre: 'María', apellido: 'García');

  final usuario = Usuario(
    id: 101,
    persona: persona,
    contrasena: 'hash123',
    estado: estadoUsuarioActivo,
  );

  group('ConfiguracionMapper', () {
    final configuracion = Configuracion(
      id: 601,
      usuario: usuario,
      notificacionesHabilitadas: true,
      idioma: 'es',
    );

    final model = ConfiguracionModel(
      id: 601,
      usuarioId: 101,
      notificacionesHabilitadas: true,
      idioma: 'es',
    );

    test('entity → model → entity produce entidad equivalente', () {
      final roundTrip = ConfiguracionMapper.fromModel(
        ConfiguracionMapper.toModel(configuracion),
        usuario,
      );
      expect(roundTrip.id, configuracion.id);
      expect(
        roundTrip.notificacionesHabilitadas,
        configuracion.notificacionesHabilitadas,
      );
      expect(roundTrip.idioma, configuracion.idioma);
      expect(roundTrip.usuario.id, usuario.id);
    });

    test('json → model → entity → model → json produce el mismo JSON', () {
      final json = model.toJson();
      final modelFromJson = ConfiguracionModel.fromJson(json);
      final entity = ConfiguracionMapper.fromModel(modelFromJson, usuario);
      final modelBack = ConfiguracionMapper.toModel(entity);
      expect(modelBack.toJson(), json);
    });
  });

  group('AceptacionTerminosMapper', () {
    final aceptacion = AceptacionTerminos(
      id: 1401,
      usuario: usuario,
      version: '1.0',
      fechaAceptacion: DateTime(2024, 1, 8),
    );

    final model = AceptacionTerminosModel(
      id: 1401,
      usuarioId: 101,
      version: '1.0',
      fechaAceptacion: '2024-01-08T00:00:00.000',
    );

    test('entity → model → entity produce entidad equivalente', () {
      final roundTrip = AceptacionTerminosMapper.fromModel(
        AceptacionTerminosMapper.toModel(aceptacion),
        usuario,
      );
      expect(roundTrip.id, aceptacion.id);
      expect(roundTrip.version, aceptacion.version);
      expect(
        roundTrip.fechaAceptacion.toIso8601String(),
        aceptacion.fechaAceptacion.toIso8601String(),
      );
    });

    test('json → model → entity → model → json produce el mismo JSON', () {
      final json = model.toJson();
      final modelFromJson = AceptacionTerminosModel.fromJson(json);
      final entity = AceptacionTerminosMapper.fromModel(modelFromJson, usuario);
      final modelBack = AceptacionTerminosMapper.toModel(entity);
      expect(modelBack.toJson(), json);
    });
  });
}
