import 'package:care_well_app/config/constraints/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('validateEmail', () {
    test('email válido retorna null', () {
      expect(validateEmail('usuario@ejemplo.com'), isNull);
    });

    test('email sin @ retorna error', () {
      expect(validateEmail('usuarioejemplo.com'), isNotNull);
    });

    test('email vacío retorna error', () {
      expect(validateEmail(''), isNotNull);
    });

    test('null retorna error', () {
      expect(validateEmail(null), isNotNull);
    });

    test('email con dominio válido retorna null', () {
      expect(validateEmail('test@test.org'), isNull);
    });
  });

  group('validatePassword', () {
    test('contraseña de 8+ caracteres retorna null', () {
      expect(validatePassword('12345678'), isNull);
    });

    test('contraseña de 7 caracteres retorna error', () {
      expect(validatePassword('1234567'), isNotNull);
    });

    test('contraseña vacía retorna error', () {
      expect(validatePassword(''), isNotNull);
    });

    test('null retorna error', () {
      expect(validatePassword(null), isNotNull);
    });
  });

  group('validatePasswordMatch', () {
    test('contraseñas iguales retornan null', () {
      expect(validatePasswordMatch('abcd1234', 'abcd1234'), isNull);
    });

    test('contraseñas distintas retornan error', () {
      expect(validatePasswordMatch('abcd1234', 'abcd5678'), isNotNull);
    });

    test('confirmación vacía retorna error', () {
      expect(validatePasswordMatch('', 'abcd1234'), isNotNull);
    });

    test('null retorna error', () {
      expect(validatePasswordMatch(null, 'abcd1234'), isNotNull);
    });
  });

  group('validateNombre', () {
    test('nombre válido retorna null', () {
      expect(validateNombre('María'), isNull);
    });

    test('nombre de 1 carácter retorna error', () {
      expect(validateNombre('A'), isNotNull);
    });

    test('nombre vacío retorna error', () {
      expect(validateNombre(''), isNotNull);
    });

    test('null retorna error', () {
      expect(validateNombre(null), isNotNull);
    });

    test('nombre de 2 caracteres retorna null', () {
      expect(validateNombre('Li'), isNull);
    });
  });

  group('validateApellido', () {
    test('apellido válido retorna null', () {
      expect(validateApellido('García'), isNull);
    });

    test('apellido de 1 carácter retorna error', () {
      expect(validateApellido('G'), isNotNull);
    });

    test('apellido vacío retorna error', () {
      expect(validateApellido(''), isNotNull);
    });

    test('null retorna error', () {
      expect(validateApellido(null), isNotNull);
    });
  });

  group('validateTelefono', () {
    test('teléfono válido retorna null', () {
      expect(validateTelefono('+54 9 11 1234 5678'), isNull);
    });

    test('campo vacío retorna null (es opcional)', () {
      expect(validateTelefono(''), isNull);
    });

    test('null retorna null (es opcional)', () {
      expect(validateTelefono(null), isNull);
    });

    test('menos de 7 dígitos retorna error', () {
      expect(validateTelefono('123456'), isNotNull);
    });

    test('teléfono con guiones válido retorna null', () {
      expect(validateTelefono('011-4444-5555'), isNull);
    });
  });

  group('validateDocumento', () {
    test('DNI de 8 dígitos retorna null', () {
      expect(validateDocumento('28456789'), isNull);
    });

    test('DNI de 7 dígitos retorna null', () {
      expect(validateDocumento('5234100'), isNull);
    });

    test('DNI con puntos retorna null', () {
      expect(validateDocumento('28.456.789'), isNull);
    });

    test('DNI de 6 dígitos retorna error', () {
      expect(validateDocumento('123456'), isNotNull);
    });

    test('DNI de 9 dígitos retorna error', () {
      expect(validateDocumento('123456789'), isNotNull);
    });

    test('vacío retorna error', () {
      expect(validateDocumento(''), isNotNull);
    });

    test('null retorna error', () {
      expect(validateDocumento(null), isNotNull);
    });

    test('solo espacios retorna error', () {
      expect(validateDocumento('   '), isNotNull);
    });
  });

  group('validateFechaNacimiento', () {
    test('fecha pasada retorna null', () {
      expect(validateFechaNacimiento(DateTime(1990, 5, 20)), isNull);
    });

    test('fecha de hoy retorna null', () {
      final hoy = DateTime.now();
      expect(
        validateFechaNacimiento(DateTime(hoy.year, hoy.month, hoy.day)),
        isNull,
      );
    });

    test('fecha futura retorna error', () {
      final manana = DateTime.now().add(const Duration(days: 1));
      expect(validateFechaNacimiento(manana), isNotNull);
    });

    test('null retorna error', () {
      expect(validateFechaNacimiento(null), isNotNull);
    });
  });
}
