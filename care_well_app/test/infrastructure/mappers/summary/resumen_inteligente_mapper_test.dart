import 'package:care_well_app/infrastructure/mappers/mappers.dart';
import 'package:care_well_app/infrastructure/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

ResumenInteligenteModel _model({
  String? resumenAcotado,
  String? estadoAnimo,
  String? resumenHabitos,
  List<ResumenDiarioHabitoModel> habitos = const [],
  List<ResumenDiarioEventoSaludModel> eventosSalud = const [],
  List<String> recomendaciones = const [],
  List<String> recordatoriosHoy = const [],
  List<String> recordatoriosManana = const [],
  List<ResumenDiarioHabitoModel> habitosManana = const [],
  DateTime? generadoEn,
  bool tieneDatos = true,
}) {
  return ResumenInteligenteModel(
    resumenAcotado: resumenAcotado,
    estadoAnimo: estadoAnimo,
    resumenHabitos: resumenHabitos,
    habitos: habitos,
    eventosSalud: eventosSalud,
    recomendaciones: recomendaciones,
    recordatoriosHoy: recordatoriosHoy,
    recordatoriosManana: recordatoriosManana,
    habitosManana: habitosManana,
    generadoEn: generadoEn,
    tieneDatos: tieneDatos,
  );
}

ResumenDiarioEventoSaludModel _evento(String descripcion, String? hora) =>
    ResumenDiarioEventoSaludModel(descripcion: descripcion, hora: hora);

void main() {
  group('ResumenInteligenteMapper.fromModel', () {
    test('mapea el caso completo', () {
      final resumen = ResumenInteligenteMapper.fromModel(
        _model(
          resumenAcotado: 'Jornada tranquila.',
          estadoAnimo: 'Alegre',
          resumenHabitos: 'Buen día de rutina.',
          habitos: const [
            ResumenDiarioHabitoModel(
              descripcion: 'Paseo matutino',
              completado: true,
            ),
            ResumenDiarioHabitoModel(descripcion: 'Cena', completado: false),
          ],
          eventosSalud: [_evento('Salida', '12:15:00')],
          recomendaciones: const ['Vigilá la digestión.'],
          recordatoriosHoy: const ['Medicación de la noche'],
          recordatoriosManana: const ['Veterinario'],
          habitosManana: const [
            ResumenDiarioHabitoModel(
              descripcion: 'Paseo matutino',
              completado: false,
            ),
          ],
          generadoEn: DateTime(2026, 8, 8, 20, 21),
        ),
      );

      expect(resumen.resumenAcotado, 'Jornada tranquila.');
      expect(resumen.totalHabitos, 2);
      expect(resumen.habitosCompletados, 1);
      expect(resumen.progresoHabitos, 0.5);
      expect(resumen.hayAtencion, isTrue);
      expect(resumen.hayManana, isTrue);
      expect(resumen.eventosSalud.single.hora, '12:15');
      expect(resumen.generadoEn, DateTime(2026, 8, 8, 20, 21));
      expect(resumen.tieneDatos, isTrue);
    });

    test('"Sin registros" se traduce a null en los tres textos', () {
      final resumen = ResumenInteligenteMapper.fromModel(
        _model(
          resumenAcotado: 'Sin registros',
          estadoAnimo: '  sin registros  ',
          resumenHabitos: 'SIN REGISTROS',
          habitos: const [
            ResumenDiarioHabitoModel(descripcion: 'Paseo', completado: true),
          ],
        ),
      );

      expect(resumen.resumenAcotado, isNull);
      expect(resumen.estadoAnimo, isNull);
      expect(resumen.resumenHabitos, isNull);
    });

    test('tieneDatos espeja el flag del backend, sin recalcularlo', () {
      final conFlag = ResumenInteligenteMapper.fromModel(
        _model(resumenAcotado: 'Sin registros', tieneDatos: true),
      );
      final sinFlag = ResumenInteligenteMapper.fromModel(
        _model(resumenAcotado: 'Jornada tranquila.', tieneDatos: false),
      );

      expect(conFlag.tieneDatos, isTrue);
      expect(sinFlag.tieneDatos, isFalse);
    });

    test('un resumen enteramente "Sin registros" no tiene contenido visible '
        'aunque el backend informe datos', () {
      final resumen = ResumenInteligenteMapper.fromModel(
        _model(
          resumenAcotado: 'Sin registros',
          estadoAnimo: 'Sin registros',
          resumenHabitos: 'Sin registros',
        ),
      );

      expect(resumen.hayContenidoVisible, isFalse);
    });

    test('un resumen con solo resumenAcotado no tiene contenido visible: ese '
        'texto alimenta el hero del Home, no la pantalla de Resumen', () {
      final resumen = ResumenInteligenteMapper.fromModel(
        _model(resumenAcotado: 'Jornada tranquila.'),
      );

      expect(resumen.tieneDatos, isTrue);
      expect(resumen.hayContenidoVisible, isFalse);
    });

    test('el comentario de hábitos alcanza para mostrar la sección', () {
      final resumen = ResumenInteligenteMapper.fromModel(
        _model(resumenHabitos: 'Cumplió con casi toda la rutina.'),
      );

      expect(resumen.habitos, isEmpty);
      expect(resumen.hayHabitos, isTrue);
      expect(resumen.hayContenidoVisible, isTrue);
    });

    test('normaliza la hora a HH:mm y descarta las inválidas', () {
      final resumen = ResumenInteligenteMapper.fromModel(
        _model(
          eventosSalud: [
            _evento('Con segundos', '08:45:00'),
            _evento('Sin cero a la izquierda', '9:05'),
            _evento('Fuera de rango', '99:99'),
            _evento('Texto libre', 'por la mañana'),
            _evento('Sin hora', null),
          ],
        ),
      );

      final porDescripcion = {
        for (final evento in resumen.eventosSalud)
          evento.descripcion: evento.hora,
      };
      expect(porDescripcion['Con segundos'], '08:45');
      expect(porDescripcion['Sin cero a la izquierda'], '09:05');
      expect(porDescripcion['Fuera de rango'], isNull);
      expect(porDescripcion['Texto libre'], isNull);
      expect(porDescripcion['Sin hora'], isNull);
    });

    test('ordena los eventos por hora y deja los sin hora al final', () {
      final resumen = ResumenInteligenteMapper.fromModel(
        _model(
          eventosSalud: [
            _evento('Mediodía', '12:15'),
            _evento('Sin hora A', null),
            _evento('Mañana', '08:45'),
            _evento('Sin hora B', null),
            _evento('Tarde', '18:00'),
          ],
        ),
      );

      expect(resumen.eventosSalud.map((e) => e.descripcion).toList(), [
        'Mañana',
        'Mediodía',
        'Tarde',
        'Sin hora A',
        'Sin hora B',
      ]);
    });

    test('descarta ítems sin descripción utilizable', () {
      final resumen = ResumenInteligenteMapper.fromModel(
        _model(
          habitos: const [
            ResumenDiarioHabitoModel(descripcion: null, completado: true),
            ResumenDiarioHabitoModel(descripcion: 'Paseo', completado: true),
          ],
          eventosSalud: [_evento('Sin registros', '10:00')],
          recomendaciones: const ['Sin registros', 'Una válida'],
        ),
      );

      expect(resumen.habitos, hasLength(1));
      expect(resumen.eventosSalud, isEmpty);
      expect(resumen.recomendaciones, ['Una válida']);
    });

    test('progresoHabitos es 0 cuando no hay hábitos', () {
      final resumen = ResumenInteligenteMapper.fromModel(
        _model(resumenAcotado: 'Algo.'),
      );

      expect(resumen.totalHabitos, 0);
      expect(resumen.progresoHabitos, 0.0);
      expect(resumen.hayHabitos, isFalse);
      expect(resumen.hayAtencion, isFalse);
      expect(resumen.hayManana, isFalse);
    });

    test('generadoEn null se propaga tal cual', () {
      final resumen = ResumenInteligenteMapper.fromModel(
        _model(resumenAcotado: 'Algo.'),
      );

      expect(resumen.generadoEn, isNull);
    });
  });
}
