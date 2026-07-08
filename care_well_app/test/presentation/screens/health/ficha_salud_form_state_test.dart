import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/screens/health/ficha_salud_form_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final persona = Persona(
    id: 2,
    nombre: 'Alicia',
    apellido: 'Rodríguez',
    documento: '5234100',
    fechaNacimiento: DateTime(1943, 7, 22),
  );

  FichaSalud fichaConDatos() => FichaSalud(
    id: 501,
    persona: persona,
    factorSanguineo: 'O+',
    obraSocial: 'PAMI',
    observaciones: 'Nota.',
    antecedentes: const [
      FichaSaludAntecedente(
        id: 511,
        nombre: 'Hipertensión',
        descripcion: 'Desc.',
        vinculoFamiliar: 'Madre',
      ),
    ],
    alergias: const [
      FichaSaludAlergia(id: 521, nombre: 'Penicilina', reaccion: 'Erupción.'),
    ],
    enfermedades: const [
      FichaSaludEnfermedad(id: 531, nombre: 'Hipotiroidismo', vigente: true),
    ],
  );

  group('FichaSaludFormState — inicialización', () {
    test('empty arranca sin factor y no puede guardarse', () {
      final state = FichaSaludFormState.empty(persona);
      expect(state.factorSanguineo, isNull);
      expect(state.canSave, isFalse);
      expect(state.antecedentes, isEmpty);
      expect(state.fichaId, 0);
    });

    test('fromFicha precarga todos los campos y puede guardarse', () {
      final state = FichaSaludFormState.fromFicha(fichaConDatos());
      expect(state.fichaId, 501);
      expect(state.factorSanguineo, 'O+');
      expect(state.obraSocial, 'PAMI');
      expect(state.observaciones, 'Nota.');
      expect(state.antecedentes, hasLength(1));
      expect(state.alergias, hasLength(1));
      expect(state.enfermedades, hasLength(1));
      expect(state.canSave, isTrue);
    });
  });

  group('FichaSaludFormState — canSave', () {
    test('true solo con factor sanguíneo seleccionado', () {
      final vacio = FichaSaludFormState.empty(persona);
      expect(vacio.canSave, isFalse);
      final conFactor = vacio.copyWith(factorSanguineo: 'A-');
      expect(conFactor.canSave, isTrue);
    });
  });

  group('FichaSaludFormState — mutaciones de listas', () {
    test('agregar/actualizar/quitar antecedente', () {
      var state = FichaSaludFormState.empty(persona);
      state = state.agregarAntecedente(
        const FichaSaludAntecedente(
          nombre: 'Diabetes',
          descripcion: 'D.',
          vinculoFamiliar: 'Propio',
        ),
      );
      expect(state.antecedentes, hasLength(1));

      state = state.actualizarAntecedente(
        0,
        const FichaSaludAntecedente(
          nombre: 'Diabetes tipo 2',
          descripcion: 'D2.',
          vinculoFamiliar: 'Propio',
        ),
      );
      expect(state.antecedentes.single.nombre, 'Diabetes tipo 2');

      state = state.quitarAntecedente(0);
      expect(state.antecedentes, isEmpty);
    });

    test('insertar restaura el ítem en su índice original (deshacer)', () {
      var state = FichaSaludFormState.fromFicha(fichaConDatos());
      final removido = state.alergias[0];
      state = state.quitarAlergia(0);
      expect(state.alergias, isEmpty);

      state = state.insertarAlergia(0, removido);
      expect(state.alergias.single.nombre, 'Penicilina');
    });

    test('agregar/quitar enfermedad', () {
      var state = FichaSaludFormState.empty(persona);
      state = state.agregarEnfermedad(
        const FichaSaludEnfermedad(nombre: 'Asma', vigente: false),
      );
      expect(state.enfermedades.single.vigente, isFalse);
      state = state.quitarEnfermedad(0);
      expect(state.enfermedades, isEmpty);
    });
  });

  group('FichaSaludFormState — toFichaSalud', () {
    test('convierte el borrador a entidad, normaliza vacíos a null', () {
      final state = FichaSaludFormState.empty(
        persona,
      ).copyWith(factorSanguineo: 'B+', obraSocial: '  ', observaciones: '');
      final ficha = state.toFichaSalud();
      expect(ficha.factorSanguineo, 'B+');
      expect(ficha.obraSocial, isNull);
      expect(ficha.observaciones, isNull);
      expect(ficha.persona.id, persona.id);
    });

    test('preserva el id de la ficha existente y las listas', () {
      final state = FichaSaludFormState.fromFicha(fichaConDatos());
      final ficha = state.toFichaSalud();
      expect(ficha.id, 501);
      expect(ficha.antecedentes, hasLength(1));
      expect(ficha.obraSocial, 'PAMI');
    });
  });
}
