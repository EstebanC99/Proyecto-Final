import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routers/app_routes.dart';
import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';
import 'ficha_salud_form_state.dart';

/// Pantalla de Ficha de salud (US-35).
///
/// Registra y mantiene la ficha clínica básica de la persona a cargo en una
/// única pantalla, con un único guardado atómico (cabecera + 3 listas).
class FichaSaludScreen extends ConsumerStatefulWidget {
  const FichaSaludScreen({super.key});

  @override
  ConsumerState<FichaSaludScreen> createState() => _FichaSaludScreenState();
}

class _FichaSaludScreenState extends ConsumerState<FichaSaludScreen> {
  /// Borrador editable en memoria (null hasta que se resuelve la carga).
  FichaSaludFormState? _form;

  /// Persona para la que se sembró el borrador (evita reseeds espurios).
  int? _seededPersonaId;

  bool _dirty = false;
  bool _saving = false;

  /// Mensaje de error del último intento de guardado (null si no hubo error).
  String? _saveErrorMessage;

  /// Marca que el usuario intentó guardar sin factor sanguíneo (resalta grid).
  bool _factorErrorVisible = false;

  final _obraSocialCtrl = TextEditingController();
  final _observacionesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // La ficha puede venir YA resuelta de otra pantalla que la haya observado
    // antes (el hub de Salud la usa para sus chips). En ese caso no hay
    // transición de estado y `ref.listen` nunca dispara, así que la siembra
    // inicial se hace acá; el listener cubre el caso contrario.
    final fichaAsync = ref.read(fichaSaludProvider);
    if (fichaAsync case AsyncData(:final value)) {
      _sembrarBorrador(value, notificar: false);
    }
  }

  /// Siembra el borrador editable a partir de [ficha] (o de su ausencia).
  ///
  /// No hace nada si ya se sembró para la persona de contexto actual, para no
  /// pisar las ediciones en curso. [notificar] queda en `false` cuando se llama
  /// antes del primer build, donde `setState` todavía no corresponde.
  void _sembrarBorrador(FichaSalud? ficha, {bool notificar = true}) {
    final persona = ref.read(personaVisualizacionSeleccionadaProvider).value;
    if (persona == null) return;
    if (_seededPersonaId == persona.id) return;

    final seeded = ficha != null
        ? FichaSaludFormState.fromFicha(ficha)
        : FichaSaludFormState.empty(persona);

    void aplicar() {
      _form = seeded;
      _seededPersonaId = persona.id;
      _dirty = false;
      _obraSocialCtrl.text = seeded.obraSocial;
      _observacionesCtrl.text = seeded.observaciones;
    }

    if (notificar) {
      setState(aplicar);
    } else {
      aplicar();
    }
  }

  @override
  void dispose() {
    _obraSocialCtrl.dispose();
    _observacionesCtrl.dispose();
    super.dispose();
  }

  // ─── Mutaciones del borrador ───────────────────────────────────────────────

  void _update(FichaSaludFormState next) {
    setState(() {
      _form = next;
      _dirty = true;
      _saveErrorMessage = null;
    });
  }

  // ─── Guardado atómico ──────────────────────────────────────────────────────

  Future<void> _guardar() async {
    final form = _form;
    if (form == null) return;
    if (!form.canSave) {
      setState(() => _factorErrorVisible = true);
      return;
    }

    setState(() {
      _saving = true;
      _saveErrorMessage = null;
      _factorErrorVisible = false;
    });

    try {
      final guardar = ref.read(guardarFichaSaludProvider);
      await guardar(form.toFichaSalud());
      if (!mounted) return;
      setState(() {
        _saving = false;
        _dirty = false;
      });
      context.pushReplacementNamed(AppRoutes.healthRecordSavedName);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _saveErrorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  // ─── Borrado local con "Deshacer" ────────────────────────────────────────────

  void _mostrarUndo(String nombre, VoidCallback deshacer) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$nombre eliminado'),
          backgroundColor: context.colors.textPrimary,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'DESHACER',
            textColor: const Color(0xFF7FD9CE),
            onPressed: deshacer,
          ),
        ),
      );
  }

  // ─── Salida con confirmación de descarte ─────────────────────────────────────

  Future<bool> _confirmarSalida() async {
    if (!_dirty) return true;
    final salir = await ConfirmDialog.show(
      context,
      title: '¿Salir sin guardar?',
      body: 'Se perderán los cambios de la ficha que no guardaste.',
      confirmLabel: 'Salir',
      accentColor: context.colors.warning,
      icon: Icons.logout_outlined,
      onConfirm: () async {},
    );
    return salir;
  }

  @override
  Widget build(BuildContext context) {
    final personaAsync = ref.watch(personaVisualizacionSeleccionadaProvider);
    final puedeVerAsync = ref.watch(puedeVerSaludProvider);
    final puedeEditar =
        ref.watch(puedeAdministrarFichaSaludProvider).value ?? false;

    // Siembra el borrador cuando llega la ficha (o su ausencia). Si ya venía
    // resuelta, la siembra inicial la hizo `initState`.
    ref.listen<AsyncValue<FichaSalud?>>(fichaSaludProvider, (prev, next) {
      next.whenData(_sembrarBorrador);
    });

    // Fuerza la resolución del provider de ficha (dispara el listener).
    final fichaAsync = ref.watch(fichaSaludProvider);

    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        if (await _confirmarSalida()) {
          navigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: context.colors.background,
        appBar: AppBar(
          title: const Text('Ficha de salud'),
          backgroundColor: context.colors.surface,
          foregroundColor: context.colors.textPrimary,
          elevation: 0,
        ),
        body: personaAsync.when(
          loading: () => const _LoadingSkeleton(),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: InlineErrorBanner(
                message: 'No se pudo cargar la ficha de salud. $e',
              ),
            ),
          ),
          data: (persona) {
            if (persona == null) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Text(
                    'Primero agregá una persona a cargo para ver su ficha de salud.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: context.colors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              );
            }

            // Defensa en profundidad: sin permiso de ver ficha no se muestra el
            // contenido (la card del hub ya aparece deshabilitada).
            final puedeVer = puedeVerAsync.value;
            if (puedeVerAsync.isLoading && puedeVer == null) {
              return const _LoadingSkeleton();
            }
            if (puedeVer != true) {
              return const _SinPermisoState();
            }

            return fichaAsync.when(
              loading: () => const _LoadingSkeleton(),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: InlineErrorBanner(
                    message: 'No se pudo cargar la ficha de salud. $e',
                  ),
                ),
              ),
              data: (_) {
                final form = _form;
                if (form == null) return const _LoadingSkeleton();
                return _buildForm(context, persona, form, puedeEditar);
              },
            );
          },
        ),
        // El footer de guardado solo se muestra si el usuario puede editar.
        bottomNavigationBar: (_form == null || !puedeEditar)
            ? null
            : _StickyFooter(
                enabled: _form!.canSave && !_saving,
                loading: _saving,
                errorMessage: _saveErrorMessage,
                onPressed: _guardar,
              ),
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    Persona persona,
    FichaSaludFormState form,
    bool puedeEditar,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: ContextChip(nombrePersona: persona.nombreCompleto),
          ),
          const SizedBox(height: AppSpacing.md),
          PersonaContextHeaderCard(persona: persona),
          const SizedBox(height: AppSpacing.xl),
          const _SectionLabel('Datos generales'),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Factor sanguíneo *',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          BloodTypeChipGrid(
            selected: form.factorSanguineo,
            showError: _factorErrorVisible && !form.canSave,
            enabled: puedeEditar,
            onSelected: (v) => _update(form.copyWith(factorSanguineo: v)),
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Obra social (opcional)',
            hint: 'Ej. PAMI, OSDE, Swiss Medical',
            controller: _obraSocialCtrl,
            enabled: puedeEditar,
            textCapitalization: TextCapitalization.words,
            onChanged: (v) => _update(form.copyWith(obraSocial: v)),
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildAntecedentes(form, puedeEditar),
          const SizedBox(height: AppSpacing.xl),
          _buildAlergias(form, puedeEditar),
          const SizedBox(height: AppSpacing.xl),
          _buildEnfermedades(form, puedeEditar),
          const SizedBox(height: AppSpacing.xl),
          AppTextField(
            label: 'Observaciones (opcional)',
            hint: 'Notas generales sobre la salud de la persona',
            controller: _observacionesCtrl,
            enabled: puedeEditar,
            keyboardType: TextInputType.multiline,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (v) => _update(form.copyWith(observaciones: v)),
          ),
        ],
      ),
    );
  }

  // ─── Secciones de lista ──────────────────────────────────────────────────────

  Widget _buildAntecedentes(FichaSaludFormState form, bool puedeEditar) {
    return HealthListSection(
      type: FichaListType.antecedentes,
      itemCount: form.antecedentes.length,
      canEdit: puedeEditar,
      onAdd: () => _altaItem(FichaListType.antecedentes),
      children: [
        for (var i = 0; i < form.antecedentes.length; i++)
          HealthListItemCard(
            key: ValueKey('ant-$i-${form.antecedentes[i].id}'),
            title: form.antecedentes[i].nombre,
            subtitles: [
              form.antecedentes[i].descripcion,
              'Vínculo: ${form.antecedentes[i].vinculoFamiliar}',
            ],
            accent: FichaListType.antecedentes.accent(context),
            onTap: puedeEditar ? () => _edicionAntecedente(i) : null,
            onDelete: puedeEditar ? () => _borrarAntecedente(i) : null,
          ),
      ],
    );
  }

  Widget _buildAlergias(FichaSaludFormState form, bool puedeEditar) {
    return HealthListSection(
      type: FichaListType.alergias,
      itemCount: form.alergias.length,
      canEdit: puedeEditar,
      onAdd: () => _altaItem(FichaListType.alergias),
      children: [
        for (var i = 0; i < form.alergias.length; i++)
          HealthListItemCard(
            key: ValueKey('ale-$i-${form.alergias[i].id}'),
            title: form.alergias[i].nombre,
            subtitles: [
              form.alergias[i].reaccion,
              if (form.alergias[i].medicamento != null)
                'Medicamento: ${form.alergias[i].medicamento}',
            ],
            accent: FichaListType.alergias.accent(context),
            onTap: puedeEditar ? () => _edicionAlergia(i) : null,
            onDelete: puedeEditar ? () => _borrarAlergia(i) : null,
          ),
      ],
    );
  }

  Widget _buildEnfermedades(FichaSaludFormState form, bool puedeEditar) {
    return HealthListSection(
      type: FichaListType.enfermedades,
      itemCount: form.enfermedades.length,
      canEdit: puedeEditar,
      onAdd: () => _altaItem(FichaListType.enfermedades),
      children: [
        for (var i = 0; i < form.enfermedades.length; i++)
          HealthListItemCard(
            key: ValueKey('enf-$i-${form.enfermedades[i].id}'),
            title: form.enfermedades[i].nombre,
            subtitles: [
              if (form.enfermedades[i].observacion != null)
                form.enfermedades[i].observacion!,
            ],
            vigente: form.enfermedades[i].vigente,
            accent: FichaListType.enfermedades.accent(context),
            onTap: puedeEditar ? () => _edicionEnfermedad(i) : null,
            onDelete: puedeEditar ? () => _borrarEnfermedad(i) : null,
          ),
      ],
    );
  }

  // ─── Alta (bottom sheet) ─────────────────────────────────────────────────────

  Future<void> _altaItem(FichaListType type) async {
    final form = _form;
    if (form == null) return;
    final result = await ItemFormBottomSheet.show(context, type: type);
    if (result is! ItemSaved) return;
    switch (type) {
      case FichaListType.antecedentes:
        _update(form.agregarAntecedente(result.item as FichaSaludAntecedente));
      case FichaListType.alergias:
        _update(form.agregarAlergia(result.item as FichaSaludAlergia));
      case FichaListType.enfermedades:
        _update(form.agregarEnfermedad(result.item as FichaSaludEnfermedad));
    }
  }

  // ─── Edición y borrado por lista ──────────────────────────────────────────────

  Future<void> _edicionAntecedente(int index) async {
    final form = _form;
    if (form == null) return;
    final result = await ItemFormBottomSheet.show(
      context,
      type: FichaListType.antecedentes,
      initial: form.antecedentes[index],
    );
    if (result is ItemSaved) {
      _update(
        form.actualizarAntecedente(index, result.item as FichaSaludAntecedente),
      );
    } else if (result is ItemDeleted) {
      _borrarAntecedente(index);
    }
  }

  void _borrarAntecedente(int index) {
    final form = _form;
    if (form == null) return;
    final item = form.antecedentes[index];
    _update(form.quitarAntecedente(index));
    _mostrarUndo(item.nombre, () {
      final actual = _form;
      if (actual == null) return;
      _update(actual.insertarAntecedente(index, item));
    });
  }

  Future<void> _edicionAlergia(int index) async {
    final form = _form;
    if (form == null) return;
    final result = await ItemFormBottomSheet.show(
      context,
      type: FichaListType.alergias,
      initial: form.alergias[index],
    );
    if (result is ItemSaved) {
      _update(form.actualizarAlergia(index, result.item as FichaSaludAlergia));
    } else if (result is ItemDeleted) {
      _borrarAlergia(index);
    }
  }

  void _borrarAlergia(int index) {
    final form = _form;
    if (form == null) return;
    final item = form.alergias[index];
    _update(form.quitarAlergia(index));
    _mostrarUndo(item.nombre, () {
      final actual = _form;
      if (actual == null) return;
      _update(actual.insertarAlergia(index, item));
    });
  }

  Future<void> _edicionEnfermedad(int index) async {
    final form = _form;
    if (form == null) return;
    final result = await ItemFormBottomSheet.show(
      context,
      type: FichaListType.enfermedades,
      initial: form.enfermedades[index],
    );
    if (result is ItemSaved) {
      _update(
        form.actualizarEnfermedad(index, result.item as FichaSaludEnfermedad),
      );
    } else if (result is ItemDeleted) {
      _borrarEnfermedad(index);
    }
  }

  void _borrarEnfermedad(int index) {
    final form = _form;
    if (form == null) return;
    final item = form.enfermedades[index];
    _update(form.quitarEnfermedad(index));
    _mostrarUndo(item.nombre, () {
      final actual = _form;
      if (actual == null) return;
      _update(actual.insertarEnfermedad(index, item));
    });
  }
}

// ─── Widgets auxiliares ────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: context.colors.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _StickyFooter extends StatelessWidget {
  const _StickyFooter({
    required this.enabled,
    required this.loading,
    required this.errorMessage,
    required this.onPressed,
  });

  final bool enabled;
  final bool loading;

  /// Mensaje del error del último intento de guardado (null si no hubo error).
  final String? errorMessage;

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (errorMessage != null) ...[
              InlineErrorBanner(
                message: errorMessage!.isNotEmpty
                    ? errorMessage!
                    : 'No se pudo guardar la ficha de salud. Reintentar',
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            SizedBox(
              width: double.infinity,
              height: AppSpacing.buttonHeight,
              child: FilledButton(
                onPressed: enabled ? onPressed : null,
                style: FilledButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  disabledBackgroundColor: context.colors.outline,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                ),
                child: loading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: context.colors.onPrimary,
                        ),
                      )
                    : Text(
                        'Guardar ficha',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: context.colors.onPrimary,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SinPermisoState extends StatelessWidget {
  const _SinPermisoState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline,
              size: 64,
              color: context.colors.textDisabled,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'No tenés permiso para ver la ficha de salud de esta persona.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: context.colors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget block(double height) => Container(
      height: height,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [block(96), block(72), block(72), block(72), block(72)],
      ),
    );
  }
}
