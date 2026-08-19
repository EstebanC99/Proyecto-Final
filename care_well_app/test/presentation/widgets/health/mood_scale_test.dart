import 'package:care_well_app/config/theme/app_palette.dart';
import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('helpers de visuales de ánimo', () {
    test('moodLevelColor mapea cada nivel al color de escala esperado', () {
      const palette = AppPalette.light;
      expect(
        moodLevelColor(palette, EstadosAnimoConst.muyMal),
        palette.moodScaleVeryBad,
      );
      expect(
        moodLevelColor(palette, EstadosAnimoConst.mal),
        palette.moodScaleBad,
      );
      expect(
        moodLevelColor(palette, EstadosAnimoConst.regular),
        palette.moodScaleNeutral,
      );
      expect(
        moodLevelColor(palette, EstadosAnimoConst.bien),
        palette.moodScaleGood,
      );
      expect(
        moodLevelColor(palette, EstadosAnimoConst.muyBien),
        palette.moodScaleVeryGood,
      );
      // Nivel desconocido → gris neutro.
      expect(moodLevelColor(palette, 99), palette.textDisabled);
    });

    test('moodLevelColor resuelve los tonos oscuros con la paleta dark', () {
      const palette = AppPalette.dark;
      expect(
        moodLevelColor(palette, EstadosAnimoConst.muyMal),
        palette.moodScaleVeryBad,
      );
      expect(
        moodLevelColor(palette, EstadosAnimoConst.muyBien),
        palette.moodScaleVeryGood,
      );
      // El mismo nivel cambia de tono según el brillo del tema.
      expect(
        moodLevelColor(AppPalette.dark, EstadosAnimoConst.regular),
        isNot(moodLevelColor(AppPalette.light, EstadosAnimoConst.regular)),
      );
    });

    test('moodEmoji mapea cada estado al emoji correcto', () {
      EstadoAnimo estado(int id) => EstadoAnimo(id: id, descripcion: '');

      expect(moodEmoji(estado(EstadosAnimoConst.muyMal)), '😞');
      expect(moodEmoji(estado(EstadosAnimoConst.mal)), '😕');
      expect(moodEmoji(estado(EstadosAnimoConst.regular)), '😐');
      expect(moodEmoji(estado(EstadosAnimoConst.bien)), '🙂');
      expect(moodEmoji(estado(EstadosAnimoConst.muyBien)), '😄');
    });
  });

  group('catálogo de niveles', () {
    test('moodLevels está ordenado de peor a mejor', () {
      expect(moodLevels.map((l) => l.level).toList(), [
        EstadosAnimoConst.muyMal,
        EstadosAnimoConst.mal,
        EstadosAnimoConst.regular,
        EstadosAnimoConst.bien,
        EstadosAnimoConst.muyBien,
      ]);
    });

    test('moodLevel devuelve el id de la entidad', () {
      expect(
        moodLevel(EstadoAnimo(id: EstadosAnimoConst.bien, descripcion: '')),
        EstadosAnimoConst.bien,
      );
    });

    test('moodEmojiForLevel cae al emoji neutro si el nivel no existe', () {
      expect(moodEmojiForLevel(EstadosAnimoConst.muyBien), '😄');
      expect(moodEmojiForLevel(99), '😐');
    });

    test('moodLabelForLevel devuelve null si el nivel no existe', () {
      expect(moodLabelForLevel(EstadosAnimoConst.regular), 'Regular');
      expect(moodLabelForLevel(99), isNull);
    });
  });
}
