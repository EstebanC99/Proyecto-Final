import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import '../shared/app_text_field.dart';
import 'ficha_salud_list_type.dart';

/// Resultado de interactuar con el [ItemFormBottomSheet].
sealed class ItemFormResult {
  const ItemFormResult();
}

/// El usuario guardó (alta o edición): [item] es la entidad resultante
/// ([FichaSaludAntecedente], [FichaSaludAlergia] o [FichaSaludEnfermedad]).
class ItemSaved extends ItemFormResult {
  const ItemSaved(this.item);
  final BaseEntity item;
}

/// El usuario eliminó el ítem (solo disponible en edición).
class ItemDeleted extends ItemFormResult {
  const ItemDeleted();
}

/// Bottom sheet reutilizable para alta/edición de un ítem de la Ficha de salud.
///
/// Un único componente parametrizado por [FichaListType]. No persiste nada
/// contra el backend: solo devuelve el resultado para actualizar el estado
/// local de la pantalla.
class ItemFormBottomSheet extends StatefulWidget {
  const ItemFormBottomSheet({super.key, required this.type, this.initial});

  final FichaListType type;

  /// Ítem existente para editar (null → alta).
  final BaseEntity? initial;

  /// Muestra el sheet y retorna el resultado (o null si se descartó).
  static Future<ItemFormResult?> show(
    BuildContext context, {
    required FichaListType type,
    BaseEntity? initial,
  }) {
    return showModalBottomSheet<ItemFormResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      builder: (_) => ItemFormBottomSheet(type: type, initial: initial),
    );
  }

  @override
  State<ItemFormBottomSheet> createState() => _ItemFormBottomSheetState();
}

class _ItemFormBottomSheetState extends State<ItemFormBottomSheet> {
  late final TextEditingController _nombreCtrl;

  /// Segundo campo: descripción (antecedente) o reacción (alergia).
  late final TextEditingController _campo2Ctrl;

  /// Tercer campo: vínculo (antecedente), medicamento (alergia),
  /// observación (enfermedad).
  late final TextEditingController _campo3Ctrl;

  /// Solo enfermedad: estado vigente.
  bool _vigente = true;

  bool _submitted = false;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController();
    _campo2Ctrl = TextEditingController();
    _campo3Ctrl = TextEditingController();
    _precargar();
  }

  void _precargar() {
    final initial = widget.initial;
    switch (initial) {
      case FichaSaludAntecedente a:
        _nombreCtrl.text = a.nombre;
        _campo2Ctrl.text = a.descripcion;
        _campo3Ctrl.text = a.vinculoFamiliar;
      case FichaSaludAlergia al:
        _nombreCtrl.text = al.nombre;
        _campo2Ctrl.text = al.reaccion;
        _campo3Ctrl.text = al.medicamento ?? '';
      case FichaSaludEnfermedad e:
        _nombreCtrl.text = e.nombre;
        _campo3Ctrl.text = e.observacion ?? '';
        _vigente = e.vigente;
      default:
        break;
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _campo2Ctrl.dispose();
    _campo3Ctrl.dispose();
    super.dispose();
  }

  /// Campos obligatorios completos según el tipo.
  bool get _isValid {
    final nombre = _nombreCtrl.text.trim();
    final campo2 = _campo2Ctrl.text.trim();
    final campo3 = _campo3Ctrl.text.trim();
    return switch (widget.type) {
      FichaListType.antecedentes =>
        nombre.isNotEmpty && campo2.isNotEmpty && campo3.isNotEmpty,
      FichaListType.alergias => nombre.isNotEmpty && campo2.isNotEmpty,
      FichaListType.enfermedades => nombre.isNotEmpty,
    };
  }

  int get _initialId => widget.initial?.id ?? 0;

  BaseEntity _buildItem() {
    final nombre = _nombreCtrl.text.trim();
    final campo2 = _campo2Ctrl.text.trim();
    final campo3 = _campo3Ctrl.text.trim();
    return switch (widget.type) {
      FichaListType.antecedentes => FichaSaludAntecedente(
        id: _initialId,
        nombre: nombre,
        descripcion: campo2,
        vinculoFamiliar: campo3,
      ),
      FichaListType.alergias => FichaSaludAlergia(
        id: _initialId,
        nombre: nombre,
        reaccion: campo2,
        medicamento: campo3.isEmpty ? null : campo3,
      ),
      FichaListType.enfermedades => FichaSaludEnfermedad(
        id: _initialId,
        nombre: nombre,
        vigente: _vigente,
        observacion: campo3.isEmpty ? null : campo3,
      ),
    };
  }

  void _guardar() {
    setState(() => _submitted = true);
    if (!_isValid) return;
    Navigator.of(context).pop(ItemSaved(_buildItem()));
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.type;
    final titulo = _isEdit
        ? 'Editar ${type.singular}'
        : 'Nuevo ${type.singular}';

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: Text(
                    titulo,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: context.colors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  color: context.colors.textSecondary,
                ),
              ],
            ),
            const Divider(height: AppSpacing.lg),
            ..._buildFields(),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              height: AppSpacing.buttonHeight,
              child: FilledButton(
                onPressed: _isValid ? _guardar : null,
                style: FilledButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  disabledBackgroundColor: context.colors.outline,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                ),
                child: Text(
                  _isEdit ? 'Guardar cambios' : 'Agregar',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: context.colors.onPrimary,
                  ),
                ),
              ),
            ),
            if (_isEdit)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Center(
                  child: TextButton(
                    onPressed: () =>
                        Navigator.of(context).pop(const ItemDeleted()),
                    style: TextButton.styleFrom(
                      foregroundColor: context.colors.error,
                    ),
                    child: Text(
                      'Eliminar ${type.singular}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFields() {
    final nombreVacio = _submitted && _nombreCtrl.text.trim().isEmpty;
    switch (widget.type) {
      case FichaListType.antecedentes:
        final descVacio = _submitted && _campo2Ctrl.text.trim().isEmpty;
        final vincVacio = _submitted && _campo3Ctrl.text.trim().isEmpty;
        return [
          _field(
            'Nombre *',
            'Ej. Hipertensión',
            _nombreCtrl,
            error: nombreVacio,
          ),
          const SizedBox(height: AppSpacing.md),
          _field(
            'Descripción *',
            'Ej. Diagnosticada en 2015, controlada con medicación',
            _campo2Ctrl,
            error: descVacio,
            multiline: true,
          ),
          const SizedBox(height: AppSpacing.md),
          _field(
            'Vínculo familiar *',
            'Ej. madre, padre, propio',
            _campo3Ctrl,
            error: vincVacio,
          ),
        ];
      case FichaListType.alergias:
        final reacVacio = _submitted && _campo2Ctrl.text.trim().isEmpty;
        return [
          _field('Nombre *', 'Ej. Penicilina', _nombreCtrl, error: nombreVacio),
          const SizedBox(height: AppSpacing.md),
          _field(
            'Reacción *',
            'Ej. Erupción cutánea y dificultad para respirar',
            _campo2Ctrl,
            error: reacVacio,
            multiline: true,
          ),
          const SizedBox(height: AppSpacing.md),
          _field('Medicamento', 'Ej. Amoxicilina (opcional)', _campo3Ctrl),
        ];
      case FichaListType.enfermedades:
        return [
          _field(
            'Nombre *',
            'Ej. Hipotiroidismo',
            _nombreCtrl,
            error: nombreVacio,
          ),
          const SizedBox(height: AppSpacing.md),
          _VigenteSwitch(
            vigente: _vigente,
            onChanged: (v) => setState(() => _vigente = v),
          ),
          const SizedBox(height: AppSpacing.md),
          _field(
            'Observación',
            'Ej. Controlada con Levotiroxina 50mcg (opcional)',
            _campo3Ctrl,
            multiline: true,
          ),
        ];
    }
  }

  Widget _field(
    String label,
    String hint,
    TextEditingController ctrl, {
    bool error = false,
    bool multiline = false,
  }) {
    return AppTextField(
      label: label,
      hint: hint,
      controller: ctrl,
      onChanged: (_) => setState(() {}),
      errorText: error ? 'Este campo es obligatorio' : null,
      keyboardType: multiline ? TextInputType.multiline : null,
      textCapitalization: TextCapitalization.sentences,
    );
  }
}

class _VigenteSwitch extends StatelessWidget {
  const _VigenteSwitch({required this.vigente, required this.onChanged});

  final bool vigente;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: context.colors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              vigente ? 'Activa' : 'Resuelta',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: context.colors.textPrimary,
              ),
            ),
          ),
          Switch(
            value: vigente,
            activeThumbColor: context.colors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
