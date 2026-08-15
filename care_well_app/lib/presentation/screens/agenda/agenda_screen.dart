import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routers/app_routes.dart';
import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

/// Pantalla principal de la agenda (US-23 / US-27).
///
/// Muestra una tira con los siete días de la semana seleccionada y el detalle
/// del día elegido, más una sección "Lo que sigue" con la próxima ocurrencia
/// posterior a ese día. Para usuarios con permiso
/// [PermisosCuidadoConst.gestionarAgenda] permite crear, editar, cancelar y
/// eliminar eventos.
class AgendaScreen extends ConsumerStatefulWidget {
  const AgendaScreen({super.key});

  @override
  ConsumerState<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends ConsumerState<AgendaScreen> {
  @override
  void initState() {
    super.initState();
    // Cada entrada a la agenda arranca en el presente: la selección de día y
    // semana vive en providers globales y, si no se reinicia, la pantalla se
    // abre donde quedó la visita anterior.
    //
    // El reinicio va en un microtask porque Riverpod prohíbe modificar un
    // provider dentro de un ciclo de vida del widget. Se resuelve antes del
    // primer frame, así que no se llega a ver la semana vieja.
    //
    // No se resuelve marcando los providers como `autoDispose` porque el
    // formulario de alta se apila encima de esta pantalla sin desmontarla: eso
    // los mantendría vivos igual, y además rompería el salto al día del evento
    // recién guardado.
    Future.microtask(() {
      if (mounted) reiniciarSeleccionAgenda(ref);
    });
  }

  /// Trunca una fecha a año-mes-día.
  DateTime _soloFecha(DateTime fecha) =>
      DateTime(fecha.year, fecha.month, fecha.day);

  /// Selecciona un día y, si cae fuera de la semana visible, mueve también la
  /// semana. Permite saltar a la ocurrencia de "Lo que sigue" sin pasos extra.
  void _seleccionarDia(DateTime dia) => seleccionarDiaAgenda(ref, dia);

  void _irASemanaAnterior() {
    final lunes = ref.read(semanaSeleccionadaProvider);
    ref.read(semanaSeleccionadaProvider.notifier).state = lunes.subtract(
      const Duration(days: 7),
    );
  }

  void _irASemanaSiguiente() {
    final lunes = ref.read(semanaSeleccionadaProvider);
    ref.read(semanaSeleccionadaProvider.notifier).state = lunes.add(
      const Duration(days: 7),
    );
  }

  /// Agrupa la cantidad de ocurrencias por día, para los pips de la tira.
  Map<DateTime, int> _cantidadPorDia(List<OcurrenciaEventoAgenda> ocurrencias) {
    final Map<DateTime, int> conteo = {};
    for (final o in ocurrencias) {
      final dia = _soloFecha(o.fechaHoraInicio.toLocal());
      conteo[dia] = (conteo[dia] ?? 0) + 1;
    }
    return conteo;
  }

  Future<void> _resolverAccion(
    BuildContext context,
    OcurrenciaEventoAgenda ocurrencia,
  ) async {
    final accion = await OcurrenciaActionSheet.show(
      context,
      ocurrencia: ocurrencia,
    );
    if (accion == null || !context.mounted) return;

    switch (accion) {
      case OcurrenciaAccion.editar:
        context.pushNamed(
          AppRoutes.agendaEventName,
          pathParameters: {'id': ocurrencia.eventoAgendaId.toString()},
        );
      case OcurrenciaAccion.cancelarOcurrencia:
        await _confirmarCancelarOcurrencia(context, ocurrencia);
      case OcurrenciaAccion.eliminar:
        await _confirmarEliminar(context, ocurrencia);
    }
  }

  Future<void> _confirmarCancelarOcurrencia(
    BuildContext context,
    OcurrenciaEventoAgenda ocurrencia,
  ) async {
    await ConfirmDialog.show(
      context,
      title: '¿Cancelar esta ocurrencia?',
      body:
          'Se cancelará únicamente el evento del día seleccionado. El resto de '
          'la serie se mantiene.',
      confirmLabel: 'Cancelar ocurrencia',
      icon: Icons.event_busy_outlined,
      onConfirm: () => ref.read(cancelarOcurrenciaProvider)(
        eventoAgendaId: ocurrencia.eventoAgendaId,
        fechaOcurrencia: ocurrencia.fechaHoraInicio,
      ),
    );
  }

  Future<void> _confirmarEliminar(
    BuildContext context,
    OcurrenciaEventoAgenda ocurrencia,
  ) async {
    await ConfirmDialog.show(
      context,
      title: ocurrencia.esRecurrente
          ? '¿Eliminar toda la serie?'
          : '¿Eliminar evento?',
      body: ocurrencia.esRecurrente
          ? 'Se eliminarán todas las ocurrencias de este evento recurrente. '
                'Esta acción no se puede deshacer.'
          : 'Esta acción no se puede deshacer.',
      confirmLabel: 'Eliminar',
      icon: Icons.delete_outline,
      onConfirm: () =>
          ref.read(eliminarEventoAgendaProvider)(ocurrencia.eventoAgendaId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final personaAsync = ref.watch(agendaPersonaContextProvider);
    final ocurrenciasAsync = ref.watch(ocurrenciasDeSemanaProvider);
    final lunesSemana = ref.watch(semanaSeleccionadaProvider);
    final diaSeleccionado = ref.watch(diaSeleccionadoProvider);
    final puedeGestionar =
        ref.watch(puedeGestionarAgendaProvider).value ?? false;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: const ContextAppBar(eyebrow: 'Calendario'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tira de la semana con los pips de cantidad de eventos.
          WeekStrip(
            lunesSemana: lunesSemana,
            diaSeleccionado: diaSeleccionado,
            cantidadPorDia: _cantidadPorDia(ocurrenciasAsync.value ?? const []),
            onSelectDia: _seleccionarDia,
            onPreviousWeek: _irASemanaAnterior,
            onNextWeek: _irASemanaSiguiente,
          ),

          Expanded(
            child: ocurrenciasAsync.when(
              loading: () => const _OcurrenciasSkeleton(),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: InlineErrorBanner(
                    message: 'No se pudo cargar la agenda. $err',
                  ),
                ),
              ),
              data: (ocurrencias) {
                if (personaAsync.value == null) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      child: Text(
                        'Primero agregá una persona a cargo para ver su agenda.',
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

                final delDia = ocurrencias
                    .where(
                      (o) =>
                          _soloFecha(o.fechaHoraInicio.toLocal()) ==
                          _soloFecha(diaSeleccionado),
                    )
                    .toList();

                return RefreshIndicator(
                  color: context.colors.primary,
                  onRefresh: () async {
                    ref.invalidate(ocurrenciasDeSemanaProvider);
                    ref.invalidate(proximaOcurrenciaProvider);
                    await ref.read(ocurrenciasDeSemanaProvider.future);
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
                    children: [
                      DayHeader(
                        dia: diaSeleccionado,
                        cantidadEventos: delDia.length,
                      ),

                      // Sin eventos en toda la semana se muestra el estado
                      // vacío completo (con CTA); si solo está vacío el día,
                      // alcanza un mensaje breve que no tape la tira ni la
                      // sección "Lo que sigue".
                      if (delDia.isEmpty && ocurrencias.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.lg,
                          ),
                          child: AgendaEmptyState(
                            puedeGestionar: puedeGestionar,
                            onCrear: puedeGestionar
                                ? () =>
                                      context.pushNamed(AppRoutes.agendaNewName)
                                : null,
                          ),
                        )
                      else if (delDia.isEmpty)
                        _SinEventosEnElDia(puedeGestionar: puedeGestionar)
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (final o in delDia)
                                OcurrenciaCard(
                                  ocurrencia: o,
                                  onTap: puedeGestionar && o.esEditable()
                                      ? () => _resolverAccion(context, o)
                                      : null,
                                ),
                            ],
                          ),
                        ),

                      // "Lo que sigue": próxima ocurrencia posterior al día.
                      _ProximaOcurrenciaSection(onVerDia: _seleccionarDia),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: puedeGestionar
          ? FloatingActionButton(
              onPressed: () => context.pushNamed(AppRoutes.agendaNewName),
              tooltip: 'Nuevo evento',
              backgroundColor: context.colors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(Icons.add, color: context.colors.onPrimary),
            )
          : null,
    );
  }
}

// ─── Sección "Lo que sigue" ───────────────────────────────────────────────────

/// Muestra la próxima ocurrencia posterior al día seleccionado.
///
/// Es informativa: al tocarla se salta a ese día en la agenda en lugar de
/// abrir las acciones de edición, que solo se ofrecen sobre los eventos del
/// día que se está viendo.
class _ProximaOcurrenciaSection extends ConsumerWidget {
  const _ProximaOcurrenciaSection({required this.onVerDia});

  final ValueChanged<DateTime> onVerDia;

  static const _nombresDiaCorto = [
    'LUN',
    'MAR',
    'MIÉ',
    'JUE',
    'VIE',
    'SÁB',
    'DOM',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proxima = ref.watch(proximaOcurrenciaProvider).value;
    if (proxima == null) return const SizedBox.shrink();

    final inicio = proxima.fechaHoraInicio.toLocal();
    final hora =
        '${inicio.hour.toString().padLeft(2, '0')}:'
        '${inicio.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: context.colors.outline, height: 1),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'LO QUE SIGUE',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          InkWell(
            onTap: () => onVerDia(inicio),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.primaryContainer,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Text(
                      '${_nombresDiaCorto[inicio.weekday - 1]} ${inicio.day}',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: context.colors.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Flexible(
                    child: Text(
                      proxima.titulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    ' · $hora',
                    style: TextStyle(
                      fontSize: 14,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Estado vacío del día ─────────────────────────────────────────────────────

/// Mensaje breve cuando el día seleccionado no tiene eventos.
///
/// Se prefiere a [AgendaEmptyState] (que ocupa la pantalla completa) porque
/// acá siempre queda visible la tira de días y la sección "Lo que sigue".
class _SinEventosEnElDia extends StatelessWidget {
  const _SinEventosEnElDia({required this.puedeGestionar});

  final bool puedeGestionar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_available_outlined,
            size: 40,
            color: context.colors.textDisabled,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'No hay eventos este día',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: context.colors.textSecondary,
            ),
          ),
          if (puedeGestionar) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Usá el botón + para agendar uno.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Skeleton de carga ────────────────────────────────────────────────────────

class _OcurrenciasSkeleton extends StatelessWidget {
  const _OcurrenciasSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          3,
          (_) => Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            height: 84,
            decoration: BoxDecoration(
              color: context.colors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
        ),
      ),
    );
  }
}
