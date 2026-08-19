import 'package:flutter/material.dart';

import '../../../config/constraints/validators.dart';
import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import '../shared/form_bottom_bar.dart';
import '../shared/form_text_field.dart';
import '../shared/unsaved_changes_guard.dart';

/// Nombre y apellido devueltos por [mostrarEditarNombreSheet].
class NombreApellido {
  const NombreApellido({required this.nombre, required this.apellido});

  final String nombre;
  final String apellido;
}

/// Abre la hoja para editar nombre y apellido del usuario.
///
/// Devuelve los valores confirmados, o `null` si el usuario salió sin guardar.
/// **No persiste nada**: los dos campos vuelven juntos para que la pantalla
/// haga un único guardado (y no dos, que dejarían un estado intermedio con el
/// nombre nuevo y el apellido viejo).
///
/// ## Por qué `enableDrag: false`
/// Se verificaron los tres caminos de salida de una hoja modal en Flutter 3.41:
/// el atrás del sistema y el tap en el fondo pasan por el `PopScope` (el
/// [UnsavedChangesGuard] los intercepta), pero **el arrastre hacia abajo lo
/// esquiva**: cierra la hoja y descarta lo tipeado sin preguntar nada. Como acá
/// hay datos que perder, se apaga el arrastre y la salida queda por atrás, por
/// el fondo y por la cruz del encabezado —que llama a `maybePop` justamente
/// para pasar por el guard—.
///
/// Hay un test por cada camino en
/// `test/presentation/widgets/profile/nombre_apellido_sheet_test.dart`: si una
/// versión futura de Flutter arregla el arrastre, ese test avisa y se puede
/// volver a habilitar.
Future<NombreApellido?> mostrarEditarNombreSheet(
  BuildContext context, {
  required String nombre,
  required String apellido,
}) {
  return showModalBottomSheet<NombreApellido>(
    context: context,
    isScrollControlled: true,
    enableDrag: false,
    backgroundColor: context.colors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSpacing.radiusXl),
      ),
    ),
    builder: (_) => _NombreApellidoSheet(nombre: nombre, apellido: apellido),
  );
}

class _NombreApellidoSheet extends StatefulWidget {
  const _NombreApellidoSheet({required this.nombre, required this.apellido});

  final String nombre;
  final String apellido;

  @override
  State<_NombreApellidoSheet> createState() => _NombreApellidoSheetState();
}

class _NombreApellidoSheetState extends State<_NombreApellidoSheet> {
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _apellidoCtrl;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.nombre);
    _apellidoCtrl = TextEditingController(text: widget.apellido);
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    super.dispose();
  }

  bool get _hayCambios =>
      _nombreCtrl.text.trim() != widget.nombre.trim() ||
      _apellidoCtrl.text.trim() != widget.apellido.trim();

  /// Primer problema de validación, listo para mostrar al pie.
  ///
  /// `FormTextField` no dibuja errores bajo el campo, así que el mensaje del
  /// validador es la única explicación que recibe el usuario: se muestra el
  /// texto concreto ("El nombre debe tener al menos 2 caracteres.") y no una
  /// ayuda genérica.
  String? get _problema =>
      validateNombre(_nombreCtrl.text) ?? validateApellido(_apellidoCtrl.text);

  void _guardar() {
    if (_problema != null) return;
    Navigator.of(context).pop(
      NombreApellido(
        nombre: _nombreCtrl.text.trim(),
        apellido: _apellidoCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final problema = _problema;

    return UnsavedChangesGuard(
      hayCambios: () => _hayCambios,
      child: Padding(
        // Sin `viewInsets.bottom`: ya lo suma `FormBottomBar`. Sumarlo también
        // acá levantaría la hoja el doble del alto del teclado.
        padding: const EdgeInsets.only(top: AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.outline,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        'Nombre y apellido',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: context.colors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    // `maybePop` y no `pop`: así la cruz también pasa por el
                    // guard de cambios sin guardar.
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.close),
                    tooltip: 'Cerrar',
                    color: context.colors.textSecondary,
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FormTextField(
                      controller: _nombreCtrl,
                      label: 'Nombre',
                      hintText: 'Ej. María',
                      accent: context.colors.primary,
                      maxLength: 60,
                      minLines: 1,
                      maxLines: 1,
                      labelPadding: const EdgeInsets.only(
                        top: AppSpacing.md,
                        bottom: AppSpacing.sm,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    FormTextField(
                      controller: _apellidoCtrl,
                      label: 'Apellido',
                      hintText: 'Ej. García',
                      accent: context.colors.primary,
                      maxLength: 60,
                      minLines: 1,
                      maxLines: 1,
                      labelPadding: const EdgeInsets.only(
                        top: AppSpacing.md,
                        bottom: AppSpacing.sm,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                ),
              ),
            ),
            FormBottomBar(
              label: 'Guardar',
              accent: context.colors.primary,
              onPressed: problema == null ? _guardar : null,
              hint: problema,
            ),
          ],
        ),
      ),
    );
  }
}
